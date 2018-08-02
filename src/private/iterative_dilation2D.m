function img = iterative_dilation2D(img, iterations)
    kernel = ones(3,3);
    for i = 1:iterations
        img = imdilate(img, kernel);
    end
end

