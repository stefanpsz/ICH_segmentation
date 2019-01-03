function [mask_low, mask_high] = compute_outlier_masks(data)
    [~,~,~,outliers] = robustcov(data, 'OutlierFraction', 0.4, 'NumTrials', 100000);
    
    [N,X] = histcounts(data(outliers), 64);
    [~, min_ind] = min(N);
    
    cutoff = (X(min_ind) + X(min_ind+1))/2;
    
    mask_low = outliers & (data < cutoff);
    mask_high = outliers & (data > cutoff);
end

