function [sCR, f, sFSR] = sfs_cv(sFS, figureOfMerit)
	C = length(sFS.classes);
	D = size(sFS.samples{1}, 1);
	  
	feat_opt = zeros(D,D);
	f_opt = zeros(1,D);
	for d = 1:D
		fprintf('SFS: %i of %i features...\n', d,D);
		if (d == 1)
			used = [];
			unused = 1:D;
		else
			used = feat_opt(feat_opt(:,d-1) > 0,d-1);
			unused = logic2ind(not(ind2logic(used',D)));
		end
		N = length(unused);
		f_i = zeros(1,N);
		for i = 1:N
			idx = [used; unused(i)];
			sCV = sFS;
			for c = 1:C
				sCV.samples{c} = sFS.samples{c}(idx,:);
			end
			[~, f_i(i)] = nfold_cross_validation(sCV, figureOfMerit); 
		end
		[f_opt(d), i_opt] = max(f_i);
		idx = [used; unused(i_opt)];
		feat_opt(1:length(idx),d) = idx;
	end
	

	% Select feature set
	[~, n_opt] = max(f_opt);
	feat_best = feat_opt(feat_opt(:,n_opt) > 0,n_opt);
	sCV = sFS;
	for c = 1:C
		sCV.samples{c} = sFS.samples{c}(feat_best,:);
	end
	[sCR, f] = nfold_cross_validation(sCV, figureOfMerit);
	
	sFSR.feat_opt = feat_opt;
	sFSR.f_opt = f_opt;
	sFSR.feat_best = feat_best;
end