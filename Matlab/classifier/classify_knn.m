% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [t, distance] = classify_knn(sC)
	
    if (strcmp(sC, 'supports_distance'))
        t = 1;
        return;
    end
    
    %% Set default parameters
	
	% No. Neighbors
	K = 5;
	% Search Method
	SearchMethod = 'kdtree';
	% Distance Metric
	DistanceMetric = 'euclidean';
	
	%% Classification
		
	[IDS, dst] = knnsearch(sC.training_set', sC.test_set', 'K', K, 'NSMethod', SearchMethod, 'Distance', DistanceMetric);
	
	C = length(sC.classes);
	N = size(sC.test_set,2);
	t = zeros(1,N);
    distances = zeros(2,N);
	for i = 1:N
		nghbr = sC.training_truth(IDS(i,:));
		% Count neighbors for each class
		nghbr = ind2logic(nghbr',C);
		cnt = sum(nghbr, 1);
		% Determine class by choosing the maximum among y
		[srt, ind] = sort(cnt, 'descend');
        winningClass = ind(1);
		t(i) = winningClass;
        % determine number of winning samples and mean distance to them
        mean_dst = mean(dst(i,nghbr(:,winningClass)));
        distances(:,i) = [srt(1), mean_dst];
    end
    
    % create one distance metric out of all
    
    distance = (distances(1,:) - distances(2,:))';
end