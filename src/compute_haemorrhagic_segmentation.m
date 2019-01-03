function nii_seg = compute_haemorrhagic_segmentation(nii_haemo, nii_flair, nii_malpem_map, nii_wmh_map, lambda)
% 
% nii_seg = compute_haemorrhagic_segmentation(nii_haemo, nii_flair, nii_malpem_map, nii_wmh_map, lambda)
%
% Automated segmentation of haemorrhage and surrounding oedema in MR sequences of patients with intracerebral haemorrhage.
%
% Required MATLAB library:
%
% Tools for NIfTI and ANALYZE image (https://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image).
%
% Inputs:
%
% - nii_haemo      : Nifti struct (obtained using load_untouch_nii) containing the registered haemorrhagic MRI sequence of the subject to segment (either T2* or SWI).
% - nii_flair      : Nifti struct (obtained using load_untouch_nii) containing the registered FLAIR sequence of the subject to segment.
% - nii_malpem_map : Nifti struct (obtained using load_untouch_nii) containing the registered MALPEM map of the subject to segment.
% - nii_wmh_map    : Nifti struct (obtained using load_untouch_nii) containing the registered white matter lesion probability map of the subject to segment.
% - lambda         : Parameter that controls the spatial amount of oedema to consider (default = 15).
%
% Outputs
%
% - nii_seg        : Nifti struct containing the image of the resulting segmentation.
%
%
% IMPORTANT: All input Nifti structs have to contained pre-registered images (usually in T1 subject space).
%
%
    if ~isequal(size(nii_haemo), size(nii_flair), size(nii_malpem_map), size(nii_wmh_map))
        error('All Nifti sequences have to be pre-registered to the same space.');
    end
      
    if nargin < 5
        lambda = 15;
    end
    
    if nargin < 4
       error('Not enough input arguments'); 
    end
    
    rng('shuffle', 'twister');

    is_3D_volume = (nii_malpem_map.hdr.dime.pixdim(4) <= 1.25);
    
    ventricular_labels = [1,2,21,22,23,24];
    csf_labels = [ventricular_labels 18];
    lesion_labels = [3,4,7:9,12,13,16,17,19,20,25:30];
    susceptibility_labels = [10,11,45,46,59:68,71,72,75,76,81,82,89:94,109:112,115,116,119:122,127:134];
    
    nii_haemo.img = double(nii_haemo.img);
    nii_flair.img = double(nii_flair.img);
    nii_wmh_map.img = double(nii_wmh_map.img);
    
    malpem_mask = (nii_malpem_map.img > 0);

    haemo_mask = (nii_haemo.img > 0);
    haemo_mask = hole_filling_closing(haemo_mask, 1, is_3D_volume);
    
    flair_mask = (nii_flair.img > 0);
    flair_mask = hole_filling_closing(flair_mask, 1, is_3D_volume);
    
    brain_mask = malpem_mask & haemo_mask & flair_mask;
    brain_mask = iterative_erosion(brain_mask, 2, is_3D_volume);

    wm_gm_mask = brain_mask & ~ismember(nii_malpem_map.img, csf_labels);   
    ventricular_mask = brain_mask & ismember(nii_malpem_map.img, ventricular_labels);
    lesion_labels_mask = brain_mask & ismember(nii_malpem_map.img, lesion_labels);
    susceptibility_labels_mask = brain_mask & ismember(nii_malpem_map.img, susceptibility_labels);

    haemo_wm_gm_hypo_voxels = false(size(nii_malpem_map.img));
    [haemo_wm_gm_hypo_voxels(wm_gm_mask), ~] = compute_outlier_masks(nii_haemo.img(wm_gm_mask));

    flair_wm_gm_hyper_voxels = false(size(nii_malpem_map.img));
    [~, flair_wm_gm_hyper_voxels(wm_gm_mask)] = compute_outlier_masks(nii_flair.img(wm_gm_mask));
    
    haemo_hypo_cc = extract_best_overlapping_cc(haemo_wm_gm_hypo_voxels, flair_wm_gm_hyper_voxels, lesion_labels_mask, susceptibility_labels_mask);
    
    flair_lesion_data = nii_flair.img(haemo_hypo_cc);
    
    lesion_mean = mean(flair_lesion_data);
    lesion_median = median(flair_lesion_data);
    
    if lesion_mean > lesion_median
        lesion_thresh = lesion_mean;
    else
        lesion_thresh = lesion_mean + (6 * (lesion_mean - lesion_median));
    end
    
    ich_voxels = haemo_hypo_cc & (nii_flair.img < lesion_thresh);
    ich_voxels = cut_weak_connections(ich_voxels, is_3D_volume);
    ich_voxels = extract_best_cc(ich_voxels);
    ich_voxels = hole_filling_closing(ich_voxels, 3, is_3D_volume);
    ich_voxels(ventricular_mask) = false;

    flair_hyper_thresh = min(nii_flair.img(flair_wm_gm_hyper_voxels));
    flair_brain_hyper_voxels = brain_mask & (nii_flair.img >= flair_hyper_thresh);

    D = bwdistgeodesic(ich_voxels | flair_brain_hyper_voxels, ich_voxels, 'quasi-euclidean');
    L = (1 + nii_wmh_map.img) .^ 2;

    w = ((D .* L) + lambda) ./ (2 .* lambda);
    flair_hyper_thresh_map = flair_hyper_thresh .* w;

    flair_hyper_voxels_map = (nii_flair.img > flair_hyper_thresh_map);
    
    oedema_voxels = brain_mask & flair_hyper_voxels_map;
    oedema_voxels = hole_filling_closing(oedema_voxels, 1, is_3D_volume);
    oedema_voxels(ich_voxels) = false;
    
    nii_seg = nii_malpem_map;
    nii_seg.img = uint8(ich_voxels + 2*oedema_voxels);
    nii_seg.hdr.dime.bitpix = 8;
    nii_seg.hdr.dime.datatype = 2;
    nii_seg.hdr.dime.glmin = min(nii_seg.img(:));
    nii_seg.hdr.dime.glmax = max(nii_seg.img(:));
end