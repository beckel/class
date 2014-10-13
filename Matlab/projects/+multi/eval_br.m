input_path = 'projects/+multi/results/br/classification/';
result_path = 'projects/+multi/results/br/';
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
    households = zeros(1,10000);
    prediction = zeros(num_properties,10000);
    truth = zeros(num_properties,10000);
    household_ids = zeros(1, 10000);
    for p = 1:num_properties
        property = comb{p,1};
        labels = comb{p,2};
        load([input_path, 'sR-', property, '_mcc_', method, '.mat']);
        sR_households = [];
        sR_truth = [];
        sR_prediction = [];
        % obtain prediction and ground truth of each property
        % sorting by household id is important to validate results later.
        for i = 1:length(sR)
            sR_households = [sR_households, sR{i}.households];
            sR_truth = [sR_truth, sR{i}.truth];
            sR_prediction = [sR_prediction, sR{i}.prediction];
        end
        for i = 1:length(sR_households)
            h = sR_households(i);
            households(h) = households(h) + 1;
            household_ids(1, h) = h;
            truth(p, h) = sR_truth(i);
            prediction(p, h) = sR_prediction(i);
        end
    end

    % select only households where each property is present
    idc = (households == num_properties);
    truth = truth(:, idc);
    prediction = prediction(:, idc);
    household_ids = household_ids(:, idc);
    
    % hamming distance
    num_households = length(household_ids);
    hamming{c} = zeros(1,num_households);
    f1score{c} = zeros(1,num_households);
    for h = 1:num_households
        labels = combinations{c}(:,2);
        f1_h = [];
        f1_y = [];
        for p = 1:num_properties
            true = 1;
            pred = 1;       
            if ~ismember(truth(p,h), labels{p})
                true = 0;
            end
            if ~ismember(prediction(p,h), labels{p})
                pred = 0;
            end
            if true ~= pred
                hamming{c}(h) = hamming{c}(h) + 1;
            end
            f1_h = [ f1_h, pred ];
            f1_y = [ f1_y, true ];
        end
        if sum(f1_h + f1_y) == 0
            f1score{c}(h) = 1;
        else
            f1score{c}(h) = 2 * (f1_h .* f1_y) / (f1_h + f1_y);
        end
    end
    
    hamming{c} = hamming{c} ./ num_properties;
    f1score{c} = sum(f1score{c}) / num_households;
    
%     %% (1) "Direct" method: combine output labels of each property
%     TN = 0; TP = 0; FN = 0; FP = 0;    
%         
%         if true == 0 && pred == 0
%             TN = TN + 1;
%         elseif true == 0 && pred == 1
%             FP = FP + 1;
%         elseif true == 1 && pred == 0
%             FN = FN + 1;
%         else
%             TP = TP + 1;
%         end
%     end    
%     confusion_simple{c} = [ TP, FN; FP, TN ];
     
end

hamming_br = hamming;
f1score_br = f1score;
save([result_path, 'results.mat'], 'hamming_br', 'f1score_br');


