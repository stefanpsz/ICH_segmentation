function img = iterative_dilation3D(img, iterations)
    kernel = ones(3,3,3);
    for i = 1:iterations
        img = imdilate(img, kernel);
    end
end

