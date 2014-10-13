% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t, distance] = classify_knn(sC)
	
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
	[IDS, dst] = knnsearch(training_set', sC.test_set', 'K', K, 'NSMethod', SearchMethod, 'Distance', DistanceMetric);
	
	C = length(sC.classes);
	N = size(sC.test_set,2);
	t = zeros(1,N);
    distance = zeros(C,N);
	for i = 1:N
		nghbr = training_truth(IDS(i,:));
		% Count neighbors for each class
		nghbr = ind2logic(nghbr',C);
		cnt = sum(nghbr, 1);
		% Determine class by choosing the maximum among y
		[~, ind] = sort(cnt, 'descend');
        winningClass = ind(1);
		t(i) = winningClass;
        % determine number of winning samples and mean distance to them
        for c = 1:C
            mean_dst = mean(dst(i,nghbr(:,c)));
            num_neighbors = cnt(c);
            % no nearest neighbor? weight by mean distance to the other
            % classes
            if num_neighbors == 0
                tmp = mean(dst(i, :));
            else
                tmp = num_neighbors - mean_dst;
            end
            distance(c,i) = tmp;
        end
    end
    
    distance = distance';
end