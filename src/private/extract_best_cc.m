function [img, best_score] = extract_best_cc(img)
    best_score = 0;
    
    cc = bwconncomp(img, 6);

    num_cc = cc.NumObjects;
    
    s = regionprops(cc, {'Area', 'BoundingBox', 'PixelIdxList'});

    if num_cc > 0
        [best_score, idx] = max(arrayfun(@(x)((s(x).Area ^ 2) / prod(s(x).BoundingBox(4:6))), 1:num_cc));

        img(:) = false;
        img(s(idx).PixelIdxList) = true;
    end
end