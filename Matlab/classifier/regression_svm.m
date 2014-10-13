% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t] = regression_svm(sC)

    if (strcmp(sC, 'supports_posterior'))
        t = 0;
        return;
    end

    % config
    rnd = sC.property;
    libsvm_train = 'lib/libsvm-3.17/svm-train';
    libsvm_predict = 'lib/libsvm-3.17/svm-predict';
    temp_folder = 'tmp/';
    training_file = [temp_folder, 'trainingRg', rnd, '.txt'];
    test_file = [temp_folder, 'testRg', rnd, '.txt'];
    model_file = [temp_folder, 'modelRg', rnd, '.txt'];
    output_file = [temp_folder, 'outRg', rnd, '.txt'];
    
    %% add constant term 
    training_set = [ sC.training_set; ones(1, size(sC.training_set, 2)) ];
    
    % store data
    libsvmwrite(training_file, sparse(sC.training_truth'), sparse(training_set'));
    libsvmwrite(test_file, sparse(sC.test_truth'), sparse(sC.test_set'));

    % training
    training_options = '';
%  	training_options = [training_options, ' -h 1']; % use no shrinking heuristic
    training_options = [training_options, ' -t 2']; % kernel type
%    training_options = [training_options, ' -b 1']; % output probabilities
% 	options = [options, ' -m 500']; % memory size
    training_options = [training_options, ' -s 3']; % svm type (default: 0)
    training_options = [training_options, ' -q']; % quiet mode
%     training_options = [training_options, ' -w1 2'];    
    unix([libsvm_train, ' ', training_options, ' ', training_file, ' ', model_file]);

    % test
    test_options = '';
%     test_options = [test_options, ' -b 1']; % output probabilities
 	test_options = [test_options, ' -q']; % quiet mode
    unix([libsvm_predict, ' ', test_options, ' ', test_file, ' ', model_file, ' ', output_file]);
    X = dlmread(output_file, ' ', 0, 0);

    % read input
    t = X(:,1)';

end
