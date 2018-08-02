function img = iterative_erosion3D(img, iterations)
    kernel = ones(3,3,3);
    for i = 1:iterations
        img = imerode(img, kernel);
    end
end

