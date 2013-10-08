% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t, distance] = classify_adaboost(sC)

    if (strcmp(sC, 'supports_distance'))
        % t = 1;
        t = 0;
        return;
    end

    % X: variables->columns
    %    observations->rows
    % Y: truth -> rows
    training_truth = sC.training_truth';
    training_set = sC.training_set';

    % RUSBoost: skewed data
    if length(sC.classes) == 2
        ens = fitensemble(training_set, training_truth, 'AdaBoostM1', 100, 'Tree');    
    else
        ens = fitensemble(training_set, training_truth, 'AdaBoostM2', 100, 'Tree');
    end

    test_set = sC.test_set';
    t = predict(ens, test_set);

%     distance = class_probabilities(:,1);

end
