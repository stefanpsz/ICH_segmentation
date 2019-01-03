function img = extract_best_overlapping_cc(img, ref, lesion_voxels, susceptibility_voxels)
    overlap = (img & ref);
    
    cc = bwconncomp(img, 6);

    num_cc = cc.NumObjects;
    
    if num_cc > 1
        s = regionprops(cc, 'Area', 'BoundingBox', 'PixelIdxList');
        
        scores = zeros(num_cc, 1);
        for idx = 1:num_cc
            cc_voxels = s(idx).PixelIdxList;
            
            num_overlap_voxels = sum(overlap(cc_voxels));
            num_lesion_voxels = sum(lesion_voxels(cc_voxels));
            num_susceptibility_voxels = sum(susceptibility_voxels(cc_voxels));
            
            weight = (num_overlap_voxels ^ 2) * sqrt((num_lesion_voxels + 1) / (num_susceptibility_voxels + 1));
            scores(idx) = weight * (s(idx).Area ^ 3) / (prod(s(idx).BoundingBox(4:6)) ^ 2);
        end

        [~, index_best_cc] = max(scores);
        img(:) = false;
        img(s(index_best_cc).PixelIdxList) = true;
    end
end