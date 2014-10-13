% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t, posterior] = classify_adaboost(sC)

    if (strcmp(sC, 'supports_posterior'))
        t = 1;
        % t = 0;
        return;
    end

    if sC.undersampling == 1
        classes = unique(sC.training_truth);
        num_classes = length(classes);
        [ num, ~ ] = hist(sC.training_truth, unique(sC.training_truth));

        indices = {};
        for i = 1:num_classes
            indices{end+1} = find(sC.training_truth == classes(i));
            indices{i} = indices{i}(1:min(num));
        end
        training_truth = sC.training_truth(:, cell2mat(indices))';
        training_set = sC.training_set(:, cell2mat(indices))';
    else
        training_truth = sC.training_truth';
        training_set = sC.training_set';
    end
    % X: variables->columns
    %    observations->rows
    % Y: truth -> rows

    if length(sC.classes) == 2
        ens = fitensemble(training_set, training_truth, 'AdaBoostM1', 100, 'Tree');    
    else
        ens = fitensemble(training_set, training_truth, 'AdaBoostM2', 100, 'Tree');
    end

    test_set = sC.test_set';
    [t, score] = predict(ens, test_set);

    % two classes: 
    posterior = score;

    t = t';

end
