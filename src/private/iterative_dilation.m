function img = iterative_dilation(img, iterations, is3D)
    if is3D
        img = iterative_dilation3D(img, iterations);
    else
        img = iterative_dilation2D(img, iterations);
    end
end

