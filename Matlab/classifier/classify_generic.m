% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [sCR, f, distance] = classify_generic(sC, figureOfMerit)
% 	fprintf('.');
	
    % Check if number of true labels is larger than number of features
    % (required, e.g., for mahalanobis classifier).
    % If not: return 0 as figure of merit and 0s in confusion matrix
    min_number_training_truth = min(histc(sC.training_truth, unique(sC.training_truth)));
    if min_number_training_truth <= size(sC.training_set,1)
        f = 0;
        sCR.confusion = zeros(length(sC.classes));
        sCR.P_d = 0;
        sCR.P_fa = 0;
        sCR.P_md = 0;
        return;
    end
    
	func = ['classify_', sC.method];
	func = str2func(func);
    
    if func('supports_distance') == 1
        [t, distance] = func(sC);
        sCR.distance = [t', distance, sC.test_truth'];
    else
        t = func(sC);
    end
	
	confusion = calc_confusion(sC.test_truth, t, length(sC.classes));
	sCR.confusion = confusion;
    
	
	N = sum(sum(confusion));
	sCR.P_d = sum(diag(confusion)) /N;
	sCR.P_fa = sum(confusion(2:end,1)) /N;
	sCR.P_md = sum(confusion(1,2:end)) /N;
	
	f = figureOfMerit.evaluate(sCR);
end