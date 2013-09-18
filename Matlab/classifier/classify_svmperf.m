% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t, distance] = classify_svmperf(sC)
	
    if (strcmp(sC, 'supports_distance'))
        t = 1;
        return;
    end

    % store training data in file
%     num_features = size(sC.training_set, 1);
%     num_samples = size(sC.training_set, 2);
%     if exist('tmp/svmdata/') == 0
%         mkdir('tmp/svmdata/');
%     end
%     fid = fopen('tmp/svmdata/training.txt', 'w');
%     for i = 1:num_samples
%         if sC.training_truth(i) == 1
%             fprintf(fid, '%d ', -1);
%         elseif sC.training_truth(i) == 2
%             fprintf(fid, '%d ', 1);
%         else
%             error('ERROR');
%         end
%         for j = 1:num_features
%             fprintf(fid, '%d:%f ', j, sC.training_set(j, i));
%         end
%         fprintf(fid, '\n');
%     end
%     fclose(fid);
    
    % store testing data in file
%     num_features = size(sC.test_set, 1);
%     num_samples = size(sC.test_set, 2);
%     if exist('tmp/svmdata/') == 0
%         mkdir('tmp/svmdata/');
%     end
%     fid = fopen('tmp/svmdata/test.txt', 'w');
%     for i = 1:num_samples
%         if sC.test_truth(i) == 1
%             fprintf(fid, '%d ', -1);
%         elseif sC.test_truth(i) == 2
%             fprintf(fid, '%d ', 1);
%         else
%             error('ERROR');
%         end
%         for j = 1:num_features
%             fprintf(fid, '%d:%f ', j, sC.test_set(j, i));
%         end
%         fprintf(fid, '\n');
%     end
%     fclose(fid);    
    
    % perform training 
%     system('lib/lasvm-source/la_svm tmp/svmdata/tmp.txt');
    
    options = '';
% 	options = [options, ' -h 1']; 
%  	options = [options, ' -t 2'];
%     options = [options, ' -b 1'];
%    options = [options, ' -q'];
    tic;
    % model = svmtrain(sC.training_truth', sC.training_set', options);
    
    model = svmperflearn(sC.training_set, sC.training_truth, '-c 1 -w 3 --t 2 --b 0');
    
    
    time = toc
    % [predict_label, ~, class_probabilities] = svmpredict(sC.test_truth', sC.test_set', model, '-b 1');
    options = '';
    options = [options, ' -q'];
    [predict_label, ~, class_probabilities] = predict(sC.test_truth', sparse(sC.test_set'), model, options);
    t = predict_label';
    distance = class_probabilities(:,1);

end