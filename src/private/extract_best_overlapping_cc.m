function img = extract_best_overlapping_cc(img, ref, lesion_voxels, susceptibility_voxels, min_num_voxels)
    overlap = (img & ref);
    
    s = regionprops(bwconncomp(img, 6), 'Area', 'BoundingBox', 'PixelIdxList');
    num_cc = numel(s);
    
    if num_cc > 0
        scores = zeros(num_cc, 1);
        for idx = 1:num_cc
            cc_voxels = s(idx).PixelIdxList;
            if numel(cc_voxels) >= min_num_voxels
                num_overlap_voxels = sum(overlap(cc_voxels));
                num_lesion_voxels = sum(lesion_voxels(cc_voxels));
                num_susceptibility_voxels = sum(susceptibility_voxels(cc_voxels));
                weight = (num_overlap_voxels ^ 2) * sqrt((num_lesion_voxels + 1) / (num_susceptibility_voxels + 1));
                scores(idx) = weight * (s(idx).Area ^ 3) / (prod(s(idx).BoundingBox(4:6)) ^ 2);
            end
        end

        [~, index_best_cc] = max(scores);
        img(:) = false;
        img(s(index_best_cc).PixelIdxList) = true;
    end
end