% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% new version of confusion matrix calculation: allows multiple samples for
% each household and takes majority vote of predictions.
function confusion = calc_confusion(truth, prediction, C, households)
	confusion = zeros(C,C);
    
    % check for majority for each household
    unique_households = unique(households);
    truth_h = zeros(1,length(unique_households));
    prediction_h = zeros(1,length(unique_households));
    
    for h = 1:length(unique_households)
        household = unique_households(h);
        tmp_pred = prediction(find(households == household));
        tmp_truth = truth(find(households == household));
        
        % mode: most frequent values
        prediction_h(h) = mode(tmp_pred);
        truth_h(h) = mode(tmp_truth);
    end
    
	for tr = 1:C
		for pr = 1:C
    		confusion(tr,pr) = sum(and(truth_h == tr, prediction_h == pr));
		end
	end
end