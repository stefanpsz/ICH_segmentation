function img = hole_filling_closing(img, iterations, is3D)
    img = iterative_dilation(img, iterations, is3D);    
    img = imfill(img, 'holes');
    img = iterative_erosion(img, iterations, is3D);
end