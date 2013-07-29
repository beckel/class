function [sCR, f, sFSR] = psfs_cv(sFS, figureOfMerit)
	C = length(sFS.classes);
	D = size(sFS.samples{1}, 1);
	P = sFS.P;
	 
	feat_opt = zeros(D,D,P);
	f_opt = zeros(D,P);
	% For each dimension iterate...
	for d = 1:D
		fprintf('P-SFS: %i of %i features...\n',d,D);
		if (d == 1)
			used = [];
			unused = (1:D)';
		else
			used = zeros(d-1,P);
			unused = zeros(D-d+1,P);
			for p = 1:P
				used(:,p) = feat_opt((feat_opt(:,d-1,p) > 0),d-1,p);
				unused(:,p) = logic2ind(not(ind2logic(used(:,p)',D)))';
			end
		end
		% Calculate figure of merit for all combinations
		P_i = size(unused,2); % P_i = P, except for first iteration
		f_i = zeros(D-d+1,P_i);
		for p = 1:P_i
			fprintf('Branch: %i...\n',p);
			D_i = size(unused,1);
			for i = 1:D_i
                if (isempty(used))
					f_idx = unused(i,p);
                else
					% Skip features from previous branches (avoid permutations)
					dup_found = false;
					for q = 1:p-1
						[fq, iq] = setdiff(used(:,q), used(:,p));
						if ((length(iq) == 1) && (unused(i,p) == fq))
							dup_found = true;
						end
					end
					if (dup_found)
						continue;
					end
					f_idx = [used(:,p); unused(i,p)];
                end
            
            
				sCV = sFS;
                for c = 1:C
                    sCV.samples{c} = sFS.samples{c}(f_idx,:);
                end
                % fprintf('i: %d\n', i);
                [~, f_i(i,p)] = nfold_cross_validation(sCV, figureOfMerit);
			end
 			% fprintf('\n');
		end
		% Check if all classifications failed
		if (all(f_i < 1e-2 | isnan(f_i), 2)) 
			sFSR.error = d;
			break;
		end
		% Choose best figures of merit
		[f_i_sorted sort_idx] = sort(f_i(:), 'descend');
		f_opt(d,:) = f_i_sorted(1:P)';
        fprintf('best %s: %f\n', figureOfMerit.printText(), max(f_opt(d,:)));
		% Choose best P feature sets
		for p = 1:P
			[f_plus_ind branch] = ind2sub(size(f_i), sort_idx(p));
			if (isempty(used))
				f_idx = unused(f_plus_ind, branch);
			else
				f_idx = [used(:,branch); unused(f_plus_ind, branch)];
			end
			feat_opt(1:length(f_idx),d,p) = f_idx;
        end
        % disp(feat_opt(1:length(f_idx),d,1));
	end
	

	% Select feature set
	[~, sort_idx] = sort(f_opt(:), 'descend');
	[iteration branch] = ind2sub(size(f_opt), sort_idx(1));
	feat_best = feat_opt(feat_opt(:,iteration,branch) > 0,iteration,branch);
	sCV = sFS;
    for c = 1:C
        sCV.samples{c} = sFS.samples{c}(feat_best,:);
    end
    [sCR, f] = nfold_cross_validation(sCV, figureOfMerit);
	
	sFSR.feat_opt = feat_opt;
	sFSR.f_opt = f_opt;
	sFSR.feat_best = feat_best;
end