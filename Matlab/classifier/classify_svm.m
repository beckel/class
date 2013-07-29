function [t, distance] = classify_svm(sC)
	
    if (strcmp(sC, 'supports_distance'))
        t = 1;
        return;
    end
        
    % Set Parameters
	params = sC.params;
	% Quiet Mode
	options = '-q';
	% Memory size in MB
% 	options = [options, ' -m 500'];
	% Use no shrinking heuristic
	options = [options, ' -h 1'];
	% SVM Type
% 	options = [options, ' -s 0'];
	% Kernel Type
% 	options = [options, ' -t 2'];
    % output probabilities
    options = [options, ' -b 1'];
	
	model = svmtrain(sC.training_truth', sC.training_set', options);
    [predict_label, ~, class_probabilities] = svmpredict(sC.test_truth', sC.test_set', model, '-b 1');
    
    t = predict_label';
    distance = class_probabilities(:,1);
end