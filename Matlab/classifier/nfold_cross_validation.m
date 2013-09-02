% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function [sCR, f] = nfold_cross_validation(sCV, figureOfMerit)
	%% Prepare indeces for S partitions	
	S = sCV.nfold;
	C = length(sCV.classes);
    households = sCV.households;
    unique_households = {};
    for c = 1:C
        unique_households{c} = unique(sCV.households{c});
    end
    
	inds = cell(C,S);
	for c = 1:C
		% changed cross validation to separate households rather than samples
        % N = size(sCV.samples{c},2);
        N = length(unique_households{c});
		M = ceil(N/S);
        s = RandStream('mcg16807','Seed',0);
        RandStream.setGlobalStream(s); 
		rand_inds = randperm(N);
        tmp = unique_households{c};
		for s = 1:S-1
			inds{c,s} = tmp(rand_inds((s-1)*M +1:s*M));
		end
		inds{c,S} = tmp(rand_inds((S-1)*M +1:N));
    end

    % instead of individual households, put all traces from each household
    % in training and test set (and therefore in inds_s)
    inds_s = cell(C,S);
    for s = 1:S
        for c = 1:C
            indices_in_samples = zeros(1, size(sCV.samples{c}, 2));
            for i = 1:length(inds{c,s})
                household = inds{c,s}(i);
                indices_in_samples = indices_in_samples + (households{c} == household);    
            end
            inds_s{c,s} = find(indices_in_samples);
        end
    end
    
    % s: column in inds that becomes test set
	for s = 1:S		
		%% Partition training and test sets		
		D = size(sCV.samples{1}, 1);
		N = 0;
		for c = 1:C
            N = N + length(inds_s{c,s});
		end
		test_set = zeros(D,N);
		test_truth = zeros(1,N);
        households = zeros(1,N);
		i = 1;
		for c = 1:C
			test_set(:,i:i+length(inds_s{c,s})-1) = sCV.samples{c}(:,inds_s{c,s});
			test_truth(i:i+length(inds_s{c,s})-1) = sCV.truth{c}(inds_s{c,s});
            households(i:i+length(inds_s{c,s})-1) = sCV.households{c}(inds_s{c,s});
			i = i + length(inds_s{c,s});
		end
		
		s_not = logic2ind(not(ind2logic(s,S)));
		N = 0;
		for c = 1:C
			N = N + length(cell2mat(inds_s(c,s_not)));
		end
		training_set = zeros(D,N);
		training_truth = zeros(1,N);
		i = 1;
		for c = 1:C
			N = length(cell2mat(inds_s(c,s_not)));
			training_set(:,i:i+N-1) = sCV.samples{c}(:,cell2mat(inds_s(c,s_not)));
			training_truth(i:i+N-1) = sCV.truth{c}(cell2mat(inds_s(c,s_not)));
			i = i + N;
		end
		
		%% Classification	
		sC.method = sCV.method;
		sC.params = sCV.params;
		sC.test_set = test_set;
		sC.training_set = training_set;
		sC.training_truth = training_truth;
		sC.test_truth = test_truth;
		sC.classes = sCV.classes;
        sC.households = households;
        sC.classification_type = sCV.classification_type;
        
        % check for NaN
        for i=1:length(sC.training_set)
            if isnan(sC.training_set(i))
                error('NaN and Inf entries should have been removed');
            end
        end
        for i=1:length(sC.test_set)
            if isnan(sC.test_set(i))
                error('NaN and Inf entries should have been removed');
            end
        end 
		sCR{s} = classify_generic(sC, figureOfMerit);
	end
	f = figureOfMerit.evaluate(sCR);
% 	fprintf('\n');
end