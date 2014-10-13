input_path = 'projects/+multi/results/power_set/classification/';
result_path = 'projects/+multi/results/power_set/';
if ~exist(result_path, 'dir')
    mkdir(result_path);
end

combinations = multi.get_combinations();

% method = 'lda_undersampling';
method = 'bayes_undersampling';
    
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
    filename = [input_path, 'sR-PS_', num2str(c), '_mcc_', method, '.mat'];
    if ~exist(filename, 'file')
        continue;
    end
    load(filename);
    households = [];
    truth = [];
    prediction = [];
    for i = 1:length(sR)
        households = [households, sR{i}.households];
        truth = [truth, sR{i}.truth];
        prediction = [prediction, sR{i}.prediction];
    end
    
    %% (2) evaluate results and compute hamming distance
    num_households = length(households);
    hamming{c} = zeros(1,num_households);
    labels = combinations{c}(:,2);
    
    t = zeros(num_households, num_properties);
    p = zeros(num_households, num_properties);
    for h = 1:num_households
        
        id = households(h);
        
        %% get truth vector (but search for each household first!)
        tmp = de2bi(truth(h)-1, 'left-msb', num_properties);
        t(h,:) = tmp;
        
        %% get prediction vector
        tmp = de2bi(prediction(h)-1, 'left-msb', num_properties);
        p(h,:) = tmp;
        
        %% obtain hamming distance for household h
        % hamming{c}(h) = pdist([p(h,:); t(h,:)], 'hamming');
        
        true_values = t(h,:);
        true_values(true_values==2) = 0;
        predicted_values = p(h,:);
        predicted_values(predicted_values==2) = 0;
        hamming{c}(h) = pdist([predicted_values; true_values], 'hamming');
        
        if sum(predicted_values + true_values) == 0
            f1score{c}(h) = 1;
        else
            f1score{c}(h) = 2 * (predicted_values .* true_values) / (predicted_values + true_values);
        end
        
    end

    f1score{c} = sum(f1score{c}) / num_households;

end

hamming_ps = hamming;
f1score_ps = f1score;
save([result_path, 'results.mat'], 'hamming_ps', 'f1score_ps');
