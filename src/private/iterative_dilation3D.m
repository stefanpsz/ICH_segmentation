function img = iterative_dilation3D(img, iterations)
    %kernel = ones(3,3,3);
    kernel = zeros(3,3,3);
    kernel(:,:,1) = [0 1 0; 1 1 1; 0 1 0];
    kernel(:,:,2) = [1 1 1; 1 1 1; 1 1 1];
    kernel(:,:,3) = [0 1 0; 1 1 1; 0 1 0];
    for i = 1:iterations
        img = imdilate(img, kernel);
    end
end

