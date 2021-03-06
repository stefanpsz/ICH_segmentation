function img = iterative_dilation2D(img, iterations)
    %kernel = ones(3,3);
    kernel = [0 1 0; 1 1 1; 0 1 0];
    for i = 1:iterations
        img = imdilate(img, kernel);
    end
end

