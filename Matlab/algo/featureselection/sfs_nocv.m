% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [sCR, f, sFSR] = sfs_nocv(sFS, figureOfMerit)
	D = size(sFS.training_set, 1);
    
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
			sCV.training_set = sFS.training_set(idx,:);
			sCV.test_set = sFS.test_set(idx,:);
			try
				[~, f_i(i)] = classify_generic(sCV, figureOfMerit);
            catch 
				f_i(i) = 0;
				fprintf('Classify failed using LDA\n');
                return;
			end
		end
		if (all(f_i < 1e-2))
			sFSR.error = d;
			break;
		end
		[f_opt(d), i_opt] = max(f_i);
		idx = [used; unused(i_opt)];
		feat_opt(1:length(idx),d) = idx;
    end 
	

	% Select feature set
	[~, n_opt] = max(f_opt);
	feat_best = feat_opt(feat_opt(:,n_opt) > 0,n_opt);
	sCV = sFS;
	sCV.training_set = sFS.training_set(feat_best,:);
	sCV.test_set = sFS.test_set(feat_best,:);
	try	
		[sCR, f] = classify_generic(sCV, figureOfMerit);
	catch
		f = 0;
		sCR = [];
	end
	fprintf('\n');
	
	sFSR.feat_opt = feat_opt;
	sFSR.f_opt = f_opt;
	sFSR.feat_best = feat_best;
end
