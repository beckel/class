% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [training_set, test_set] = collect_feature_vectors_nocv(feat_set, ids, training_week)
	training_set = cell(1, length(ids));
	test_set = cell(1, length(ids));
	
	avg_time = 0;
	M = length(ids);
	for i = 1:M
		tic;

		id = ids(i);
		sUser = get_weekly_consumption(id, 'cer_ireland');
		% Training Set
		training_set{i} = compose_featureset(sUser.consumption(training_week,:)', feat_set);
		if (any(isnan(training_set{i})))
			training_set{i} = [];
		end
		
		idx = logic2ind(not(ind2logic(training_week, size(sUser.consumption,1))));
		temp_samples = cell(1,length(idx));
		for n = 1:length(idx)
			temp_samples{n} = compose_featureset(sUser.consumption(idx(n),:)', feat_set);
			if (any(isnan(temp_samples{n})))
				temp_samples{n} = [];
			end
		end
		test_set{i} = cell2mat(temp_samples);

		t = toc;
		avg_time = (avg_time * (i-1) + t * 1) / i;
		eta = avg_time * (M - i);
		fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/M), i, M, seconds2str(eta));
	end
	training_set = cell2mat(training_set);
	test_set = cell2mat(test_set);
end