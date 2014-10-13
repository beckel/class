% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [prediction] = classify_knn(sC)
	
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
    else
        training_truth = sC.training_truth;
        training_set = sC.training_set;
    end
    
    %% Set default parameters
	% No. Neighbors
	K = 7;
	% Search Method
	SearchMethod = 'kdtree';
	% Distance Metric
	DistanceMetric = 'euclidean';
	
	%% Classification
	[IDS, ~] = knnsearch(training_set', sC.test_set', 'K', K, 'NSMethod', SearchMethod, 'Distance', DistanceMetric);
	
	C = length(sC.classes);
	N = size(sC.test_set,2);
	prediction = zeros(1,N);
	for i = 1:N
		nghbr = training_truth(IDS(i,:));
		% Count neighbors for each class
		nghbr = ind2logic(nghbr',C);
		cnt = sum(nghbr, 1);
		% Determine class by choosing the maximum among y
		[~, ind] = sort(cnt, 'descend');
        prediction(i) = ind(1);
    end
end