% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t, posterior] = classify_svm(sC)

    if (strcmp(sC, 'supports_posterior'))
        t = 1;
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
        training_truth = sC.training_truth(:, cell2mat(indices));
        training_set = sC.training_set(:, cell2mat(indices));
        undersampling_text = '_undersampling';
    else
        training_truth = sC.training_truth;
        training_set = sC.training_set;
        undersampling_text = '';
    end
        
    % config
    rnd = sC.property;
    libsvm_train = 'lib/libsvm-3.17/svm-train';
    libsvm_predict = 'lib/libsvm-3.17/svm-predict';
    temp_folder = 'tmp/';
    training_file = [temp_folder, 'trainingCl', rnd, undersampling_text, '.txt'];
    test_file = [temp_folder, 'testCl', rnd, undersampling_text, '.txt'];
    model_file = [temp_folder, 'modelCl', rnd, undersampling_text, '.txt'];
    output_file = [temp_folder, 'outCl', rnd, undersampling_text, '.txt'];
    
    % store data
    libsvmwrite(training_file, sparse(training_truth'), sparse(training_set'));
    libsvmwrite(test_file, sparse(sC.test_truth'), sparse(sC.test_set'));
    
    % training
    training_options = '';
%  	training_options = [training_options, ' -h 1']; % use no shrinking heuristic
    training_options = [training_options, ' -t 2']; % kernel type
    training_options = [training_options, ' -b 1']; % output probabilities
% 	options = [options, ' -m 500']; % memory size
    training_options = [training_options, ' -s 0']; % svm type (default: 0)
    training_options = [training_options, ' -q']; % quiet mode
%     training_options = [training_options, ' -w1 2'];    
    unix([libsvm_train, ' ', training_options, ' ', training_file, ' ', model_file]);
    
    % test
    test_options = '';
    test_options = [test_options, ' -b 1']; % output probabilities
 	test_options = [test_options, ' -q']; % quiet mode
    unix([libsvm_predict, ' ', test_options, ' ', test_file, ' ', model_file, ' ', output_file]);
    X = dlmread(output_file, ' ', 1, 0);

    % read input
    t = X(:,1)';
    posterior = X(:, 2:end);
end

