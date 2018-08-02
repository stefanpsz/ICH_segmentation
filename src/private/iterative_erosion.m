function img = iterative_erosion(img, iterations, is3D)
    if is3D
        img = iterative_erosion3D(img, iterations);
    else
        img = iterative_erosion2D(img, iterations);
    end
end

