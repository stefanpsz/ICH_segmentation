function img = cut_weak_connections(img, is3D)
    if is3D
        mask1 = false(3,3,3);
        mask2 = false(3,3,3);
        mask3 = false(3,3,3);
        
        mask1(:,:,2) = logical([0 1 0; 0 1 0; 0 1 0]);
        mask2(:,:,2) = logical([0 0 0; 1 1 1; 0 0 0]);
        mask3(:,:,1) = logical([0 0 0; 0 1 0; 0 0 0]);
        mask3(:,:,2) = logical([0 0 0; 0 1 0; 0 0 0]);
        mask3(:,:,3) = logical([0 0 0; 0 1 0; 0 0 0]);
    else
        mask1 = logical([0 1 0; 0 1 0; 0 1 0]);
        mask2 = logical([0 0 0; 1 1 1; 0 0 0]);
    end

    img_copy = logical(img);
    
    img_size = size(img_copy);
    
    [loc_x, loc_y, loc_z] = ind2sub(img_size, find(img_copy));
    
    num_points = numel(loc_x);
    
    for p = 1:num_points
        x = loc_x(p);
        y = loc_y(p);
        z = loc_z(p);
        
        if x > 1 && x < img_size(1)-1 && y > 1 && y < img_size(2)-1 && z > 1 && z < img_size(3)-1
            if is3D
               patch = img(x-1:x+1,y-1:y+1,z-1:z+1);
               if isequal(mask1, patch) || isequal(mask2, patch) || isequal(mask3, patch)
                   img_copy(x,y,z) = false;
               end
            else
                patch = img(x-1:x+1,y-1:y+1,z);
                if isequal(mask1, patch) || isequal(mask2, patch)
                   img_copy(x,y,z) = false;
                end
            end
        end
    end
    
    img = img_copy;
end

