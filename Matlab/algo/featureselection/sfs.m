% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [sCR, sFSR] = sfs(sFS, figureOfMerit, log)

   num_classes = length(sFS.classes);
	D = size(sFS.samples{1}, 1);

    if exist('num_features', 'var') == 0
        num_features = D;
    end
    
    if exist('exact_number', 'var') == 0
        exact_number = 0;
    end

    log.normal('Feature selection using SFS - %d features\n', num_features);
                    
	feat_opt = zeros(num_features,num_features);
	f_opt = zeros(1,num_features);
	for d = 1:num_features
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
			for c = 1:num_classes
				sCV.samples{c} = sFS.samples{c}(idx,:);
			end
			[~, f_i(i)] = nfold_cross_validation(sCV, figureOfMerit); 
		end
		[f_opt(d), i_opt] = max(f_i);
		idx = [used; unused(i_opt)];
		feat_opt(1:length(idx),d) = idx;
        log.debug('  Added %d - current set: ', unused(i_opt));
        log.write_comma_separated_list(feat_opt(1:d, d));
        log.debug(' - C: %f\n', f_opt(d));

    end
	
    if exact_number == 0
        % Select best feature set
        [~, n_opt] = max(f_opt);
        feat_best = feat_opt(feat_opt(:,n_opt) > 0,n_opt);
    else
        % Select best feature set with k features
        feat_best = feat_opt(:,end);
    end
    sCV = sFS;
    for c = 1:num_classes
        sCV.samples{c} = sFS.samples{c}(feat_best,:);
    end
    [sCR, ~] = nfold_cross_validation(sCV, figureOfMerit);

    sFSR.f_opt = f_opt;
    sFSR.feat_best = feat_best;
end
