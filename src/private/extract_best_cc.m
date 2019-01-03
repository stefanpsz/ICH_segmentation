function img = extract_best_cc(img)
    cc = bwconncomp(img, 6);

    num_cc = cc.NumObjects;

    if num_cc > 1
        s = regionprops(cc, {'Area', 'BoundingBox', 'PixelIdxList'});
        
        scores = arrayfun(@(x)((s(x).Area ^ 3) / (prod(s(x).BoundingBox(4:6)) ^ 2)), 1:num_cc);
        [~, index_best_cc] = max(scores);

        img(:) = false;
        img(s(index_best_cc).PixelIdxList) = true;
    end
end