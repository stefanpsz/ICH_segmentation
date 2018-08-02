function img = iterative_erosion2D(img, iterations)
    kernel = ones(3,3);
    for i = 1:iterations
        img = imerode(img, kernel);
    end
end

