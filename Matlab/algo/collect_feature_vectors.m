function samples = collect_feature_vectors(feat_set, ids, N)
	samples = cell(1, length(ids));
	
	avg_time = 0;
	M = length(ids);
	for i = 1:M
		tic;

		id = ids(i);
		Consumption = get_weekly_consumption(id, 'cer_ireland');
		idx = randperm(size(Consumption.consumption,1));
		idx = idx(1:N);
		temp_samples = cell(1,N);
		for n = 1:length(idx)
			temp_samples{n} = compose_featureset(Consumption.consumption(n,:)', feat_set);
			if (any(isnan(temp_samples{n})))
				temp_samples{n} = [];
			end
		end
		samples{i} = cell2mat(temp_samples);

		t = toc;
		avg_time = (avg_time * (i-1) + t * 1) / i;
		eta = avg_time * (M - i);
		fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/M), i, M, seconds2str(eta));
	end
	samples = cell2mat(samples);
end