function [thresh_hypo, thresh_hyper] = compute_intensity_thresholds(data, factor)
    res = compute_robust_statistics(data(:));
    thresh_hypo = res.center - (factor .* sqrt(diag(res.cov)'));
    thresh_hyper = res.center + (factor .* sqrt(diag(res.cov)'));
end

