% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [sCR, f] = classify_generic(sC, figureOfMerit)

    % normalization with zscore
    data = [ sC.training_set, sC.test_set ];
    data_normalized = zscore(data, 0, 2);
    training_size = size(sC.training_set, 2);
    sC.training_set = data_normalized(:,1:training_size);
    sC.test_set = data_normalized(:,training_size+1:end);
    
    % Check if number of true labels is larger than number of features
    % (required, e.g., for mahalanobis classifier).
    % If not: return 0 as figure of merit and 0s in confusion matrix
    if strcmp(sC.type, 'classification') == 1
        min_number_training_truth = min(histc(sC.training_truth, unique(sC.training_truth)));
        if min_number_training_truth <= size(sC.training_set,1)
            f = 0;
            sCR.confusion = zeros(length(sC.classes));
            sCR.P_d = 0;
            sCR.P_fa = 0;
            sCR.P_md = 0;
            return;
        end
    end
    
    if strcmp(sC.type, 'classification') == 1
        func = ['classify_', sC.method];
    else
        func = ['regression_', sC.method];
    end
    func = str2func(func);
    
    if func('supports_posterior') == 1
        [t, posterior] = func(sC);
        sCR.posterior = posterior;
    else
        t = func(sC);
    end
	
    sCR.truth = sC.test_truth;
    sCR.households = sC.households;
    sCR.prediction = t;
    
    % check if household was classified correctly by evaluating the
    % majority of weeks that were classified
    if strcmp(sC.type, 'classification') == 1
        confusion = calc_confusion(sC.test_truth, t, length(sC.classes), sC.households);
        sCR.confusion = confusion;

        N = sum(sum(confusion));
        sCR.P_d = sum(diag(confusion)) /N;
        sCR.P_fa = sum(confusion(2:end,1)) /N;
        sCR.P_md = sum(confusion(1,2:end)) /N;
    else
        sCR.p = size(sC.training_set, 1);
    end
    
	f = figureOfMerit.evaluate(sCR);
end