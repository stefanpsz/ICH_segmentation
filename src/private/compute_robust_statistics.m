function res = compute_robust_statistics(data)
    num_points = numel(data(:));
    if num_points > 500000
        indices = randperm(num_points, 500000);
    else
        indices = 1:num_points;
    end
    
    res = mcdcov(data(indices), 'alpha', 0.6, 'ntrial', 50000, 'plots', 0);
end