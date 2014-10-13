% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t] = regression_linear(sC)

    if (strcmp(sC, 'supports_posterior'))
        t = 0;
        return;
    end
    
    training_set = sC.training_set';
    training_truth = sC.training_truth';
    test_set = sC.test_set;
    test_truth = sC.test_truth;
    
    % b: coefficient estimates
    % bint: 95% estimates of the coefficient estimates
    % r: residuals
    % rint: outlier detection
    % http://www.mathworks.ch/ch/help/stats/regress.html
    % [b1,bint1,r1,rint1,stats1] = regress(training_truth, sC.training_set');
    
    %% with constant term 
    X = [ ones(size(training_set, 1), 1), training_set];
    y = training_truth;
    [b,bint,r,rint,stats] = regress(y, X);
    y_hat = b(1) + b(2:end)' * test_set;
    
    % not needed later
    sR.prediction = y_hat;
    sR.truth = test_truth;
    r2 = rsquare(sR);
    
    t = y_hat;
     
%     sC.training_truth
%     sC.training_set
%     sC.test_truth
%     sC.test_set

end
