clearvars;

input_path = 'projects/+multi/results/pcc/classification/';
result_path = 'projects/+multi/results/pcc/';
if ~exist(result_path, 'dir')
    mkdir(result_path);
end

combinations = multi.get_combinations();

method = 'lda_undersampling';
    
%% First
% Get truth and prediction values for each property
% Compute number of matches per household (equal weight)"
num_combinations = length(combinations);
confusion_simple = cell(1,num_combinations);
hamming = cell(1,num_combinations);
f1score = cell(1, num_combinations);
for c = 1:length(combinations)
    fprintf('Processing combination %d...\n', c);
    comb = combinations{c};
    num_properties = size(comb,1);
    
    %% (1) get a list of all households and all the data
    for p = 1:num_properties
        load([input_path, 'sR-PCC_', num2str(c), '.', num2str(p), '_mcc_', method, '.mat']);
        sR_households = [];
        sR_truth = [];
        sR_prediction = [];
        sR_posterior = [];
        sR_index = [];
        for i = 1:length(sR)
            sR_households = [sR_households, sR{i}.households];
            sR_truth = [sR_truth, sR{i}.truth];
            sR_prediction = [sR_prediction, sR{i}.prediction];
            sR_posterior = [sR_posterior; sR{i}.posterior];
            if p == 1
                sR_index = [];
            else
                sR_index = [sR_index; sR{i}.index];
            end
        end
        [households{p}, idx] = sort(sR_households);
        truth{p} = sR_truth(idx);
        prediction{p} = sR_prediction(idx);
        posterior{p} = sR_posterior(idx);
        if p == 1
            index{p} = [];
        else
            index{p} = sR_index(idx);
        end
    end
    
    %% (2) evaluate results and compute hamming distance
    num_households = length(households{1});
    hamming{c} = zeros(1,num_households);
    labels = combinations{c}(:,2);
    
    t = zeros(num_households, num_properties);
    for h = 1:num_households
        
        id = households{1}(h);
        
        %% get truth vector (but search for each household first!)
        for p = 1:num_properties
            t(h,p) = truth{p}(2^(p-1)*h);
        end

        %% get prediction vector
        % compute probability for each combination
        K = num_properties;
        probabilities = zeros(1, 2^(K+1)-1);
        paths = de2bi(0:2^K-1, 'left-msb');
        leaf_probabilities = zeros(1,2^K);
        
        % construct tree
        for i = 1:K
            idc = find(households{i} == id);
            for j = 1:length(idc)
                probabilities(2^i+2*(j-1)) = 1-posterior{i}(idc(j));
                probabilities(2^i+2*(j-1)+1) = posterior{i}(idc(j));
            end
        end
        
        % traverse tree and compute probabilities at each node
        for p = 1:size(paths,1)
            probability = 1;
            path = paths(p,:);
            iter = 1;
            for n = 1:length(path)
                node = path(n);
                if node == 0
                    iter = 2*iter;
                    tmp = probabilities(iter);
                    probability = probability * probabilities(iter);
                    
                else
                    iter = 2*iter + 1;
                    tmp = probabilities(iter);
                    probability = probability * probabilities(iter);
                end
            end
            leaf_probabilities(p) = probability;
        end
        
        %% TODO: CREATE POSTERIOR PROBABILITIES AND SAVE WITH THE REST!
        
        % find max and store predicted path
        [~, max_idx] = max(leaf_probabilities);
        p = [];
        p(h,:) = paths(max_idx,:);
        
        %% obtain hamming distance for household h
        true_values = t(h,:);
        true_values(true_values==2) = 0;
        predicted_values = p(h,:);
        hamming{c}(h) = pdist([predicted_values; true_values], 'hamming');
        
        if sum(predicted_values + true_values) == 0
            f1score{c}(h) = 1;
        else
            f1score{c}(h) = 2 * (predicted_values .* true_values) / (predicted_values + true_values);
        end
    end
    f1score{c} = sum(f1score{c}) / num_households;
    
end

hamming_pcc = hamming;
f1score_pcc = f1score;
save([result_path, 'results.mat'], 'hamming_pcc', 'f1score_pcc');


