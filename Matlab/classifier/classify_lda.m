% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t, distance] = classify_lda(sC)

    if (strcmp(sC, 'supports_distance'))
        t = 1;
        return;
    end
    
    [t, ~, ~, ~, ~, distance] = classify_distance_decision_boundary(sC.test_set', sC.training_set', sC.training_truth', 'linear');
	t = t';
end 