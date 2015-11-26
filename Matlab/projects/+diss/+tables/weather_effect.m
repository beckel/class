% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

%% Preset Files 

result_path_new = 'projects/+diss/results/classification_weather_pca/';
result_path_old = 'projects/+energy/results/classification_all/';
table_path = 'projects/+diss/+tables/weather_effect/';

labels = { ...
        'Singles';...
        'All_Employed';...
        'Unoccupied';...
        'Families';...
        'NoKids';...
        'eCooking';...
        'Retired';...
        'Persons';...
        'Employment';...
        'Floorarea';...
        'Age';...
        'OldHouses';...
        'HouseType';...
        'Income';...
        'LightBulbs';...
        'SocialClass';...
        'Devices';...
        'Bedrooms';...
    };

labels_in_table = { ...
    'single';...
    'all\_employed';...
    'unoccupied';...
    'family';...
    'children';...
    'cooking';...
    'retirement';...
    '\#residents';...
    'employment';...
    'floor\_area';...
    'age\_person';...
    'age\_house';...
    'house\_type';...
    'income';...
    'lightbulbs';...
    'social\_class';...
    '\#appliances';...
    '\#bedrooms';...
};

num_classes = [ 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 2, 2, 2, 2, 3, 3, 4 ];

filename = 'weather_effect_content.tex';
weeks = 1:75;
min_weeks_available = 50;
% weeks = 26;
% min_weeks_available = 0;

method_acc = 'lda';
method_mcc = 'lda_undersampling';

num_labels = length(labels);
num_weeks = length(weeks);
num_households = 10000;

prediction_accuracy = zeros(num_labels, num_weeks, num_households);
truth_accuracy = zeros(num_labels, num_households);
prediction_mcc = zeros(num_labels, num_weeks, num_households);
truth_mcc = zeros(num_labels, num_households);
majority_prediction_accuracy = zeros(num_labels, num_households);
majority_prediction_mcc = zeros(num_labels, num_households);

mccs = nan(num_labels, num_weeks);
accuracies = nan(num_labels, num_weeks);

mccs_majority = zeros(1, num_labels);
accuracies_majority = zeros(1, num_labels);

result = zeros(length(labels)+1, 6);

%% USE OLD PATH FOR OLD RESULTS
for l=1:num_labels
    label = labels{l};
    fprintf('Processing characteristic %s...\n', label);

    for w = 1:num_weeks
        week = weeks(w);
        path = [ result_path_old, num2str(week), '/sffs/'];

        %% MCC
        load([path, 'sR-', label, '_mcc_', method_mcc, '.mat']);
        mccs(l, week) = mcc(sR);
        sR_households = [];
        sR_prediction = [];
        sR_truth = [];
        for f = 1:length(sR)
            sR_households = [sR_households, sR{f}.households];
            sR_prediction = [sR_prediction, sR{f}.prediction];
            sR_truth = [sR_truth, sR{f}.truth];
        end
        for h = 1:length(sR_households)
            household = sR_households(h);
            prediction_mcc(l, w, household) = sR_prediction(h);
            truth_mcc(l, household) = sR_truth(h);
        end

        %% Accuracy
        load([path, 'sR-', label, '_accuracy_', method_acc, '.mat']);
        accuracies(l, week) = accuracy(sR);
        sR_households = [];
        sR_prediction = [];
        sR_truth = [];
        for f = 1:length(sR)
            sR_households = [sR_households, sR{f}.households];
            sR_prediction = [sR_prediction, sR{f}.prediction];
            sR_truth = [sR_truth, sR{f}.truth];
        end
        for h = 1:length(sR_households)
            household = sR_households(h);
            prediction_accuracy(l, w, household) = sR_prediction(h);
            truth_accuracy(l, household) = sR_truth(h);
        end
    end

    %% Select households with at least 'min_weeks_available' readings and take majority vote
    for h = 1:10000
        prediction_available = find(prediction_mcc(l, :, h) > 0);
        if length(prediction_available) > min_weeks_available
            t = truth_mcc(l, h);
            p = prediction_mcc(l, prediction_available, h);
            majority_prediction_mcc(l, h) = mode(p);
        end
    end

    %% Select households with at least 'min_weeks_available' readings and take majority vote
    for h = 1:10000
        prediction_available = find(prediction_accuracy(l, :, h) > 0);
        if length(prediction_available) > min_weeks_available
            t = truth_accuracy(l, h);
            p = prediction_accuracy(l, prediction_available, h);
            majority_prediction_accuracy(l, h) = mode(p);
        end
    end

    %% Confusion matrix
    C = max(truth_mcc(l, :));
    confusion_mcc = zeros(max(truth_mcc(l, :)));
    for c_row = 1:C
        for c_col = 1:C
            num = sum(truth_mcc(l, :) == c_row & majority_prediction_mcc(l, :) == c_col);
            confusion_mcc(c_row, c_col) = num;
        end
    end

    C = max(truth_accuracy(l, :));
    confusion_accuracy = zeros(max(truth_accuracy(l, :)));
    for c_row = 1:C
        for c_col = 1:C
            num = sum(truth_accuracy(l, :) == c_row & majority_prediction_accuracy(l, :) == c_col);
            confusion_accuracy(c_row, c_col) = num;
        end
    end

    %% MCC
    tmp_mccs = mccs(l,:);
    tmp_mccs = tmp_mccs(~isnan(tmp_mccs));
    majority_vote_mcc = mcc(confusion_mcc);

    %% Accuracy
    tmp_accuracies = accuracies(l,:);
    tmp_accuracies = tmp_accuracies(~isnan(tmp_accuracies));
    majority_vote_accuracy = accuracy(confusion_accuracy);

    %% Improvement      
    num_households_available = sum(majority_prediction_mcc(l,:) > 0);
    fprintf('%d households available in the test set more than %d weeks.\n', num_households_available, min_weeks_available);
    result(l, 1) = 100*majority_vote_accuracy;
    result(l, 4) = majority_vote_mcc;
    accuracies_majority(l) = majority_vote_accuracy;
    mccs_majority(l) = majority_vote_mcc;
end
result(end, 1) = 100 * mean(accuracies_majority);
result(end, 4) = mean(mccs_majority);

%% NOW DO EXACTLY THE SAME WITH NEW PATH (INCLUDING WEATHER)
    %% USE OLD PATH FOR OLD RESULTS
for l=1:num_labels
    label = labels{l};
    fprintf('Processing characteristic %s...\n', label);

    for w = 1:num_weeks
        week = weeks(w);
        path = [ result_path_new, num2str(week), '/sffs/'];

        %% MCC
        load([path, 'sR-', label, '_mcc_', method_mcc, '.mat']);
        mccs(l, week) = mcc(sR);
        sR_households = [];
        sR_prediction = [];
        sR_truth = [];
        for f = 1:length(sR)
            sR_households = [sR_households, sR{f}.households];
            sR_prediction = [sR_prediction, sR{f}.prediction];
            sR_truth = [sR_truth, sR{f}.truth];
        end
        for h = 1:length(sR_households)
            household = sR_households(h);
            prediction_mcc(l, w, household) = sR_prediction(h);
            truth_mcc(l, household) = sR_truth(h);
        end

        %% Accuracy
        load([path, 'sR-', label, '_accuracy_', method_acc, '.mat']);
        accuracies(l, week) = accuracy(sR);
        sR_households = [];
        sR_prediction = [];
        sR_truth = [];
        for f = 1:length(sR)
            sR_households = [sR_households, sR{f}.households];
            sR_prediction = [sR_prediction, sR{f}.prediction];
            sR_truth = [sR_truth, sR{f}.truth];
        end
        for h = 1:length(sR_households)
            household = sR_households(h);
            prediction_accuracy(l, w, household) = sR_prediction(h);
            truth_accuracy(l, household) = sR_truth(h);
        end
    end

    %% Select households with at least 'min_weeks_available' readings and take majority vote
    for h = 1:10000
        prediction_available = find(prediction_mcc(l, :, h) > 0);
        if length(prediction_available) > min_weeks_available
            t = truth_mcc(l, h);
            p = prediction_mcc(l, prediction_available, h);
            majority_prediction_mcc(l, h) = mode(p);
        end
    end

    %% Select households with at least 'min_weeks_available' readings and take majority vote
    for h = 1:10000
        prediction_available = find(prediction_accuracy(l, :, h) > 0);
        if length(prediction_available) > min_weeks_available
            t = truth_accuracy(l, h);
            p = prediction_accuracy(l, prediction_available, h);
            majority_prediction_accuracy(l, h) = mode(p);
        end
    end

    %% Confusion matrix
    C = max(truth_mcc(l, :));
    confusion_mcc = zeros(max(truth_mcc(l, :)));
    for c_row = 1:C
        for c_col = 1:C
            num = sum(truth_mcc(l, :) == c_row & majority_prediction_mcc(l, :) == c_col);
            confusion_mcc(c_row, c_col) = num;
        end
    end

    C = max(truth_accuracy(l, :));
    confusion_accuracy = zeros(max(truth_accuracy(l, :)));
    for c_row = 1:C
        for c_col = 1:C
            num = sum(truth_accuracy(l, :) == c_row & majority_prediction_accuracy(l, :) == c_col);
            confusion_accuracy(c_row, c_col) = num;
        end
    end

    %% MCC
    tmp_mccs = mccs(l,:);
    tmp_mccs = tmp_mccs(~isnan(tmp_mccs));
    majority_vote_mcc = mcc(confusion_mcc);

    %% Accuracy
    tmp_accuracies = accuracies(l,:);
    tmp_accuracies = tmp_accuracies(~isnan(tmp_accuracies));
    majority_vote_accuracy = accuracy(confusion_accuracy);

    %% Improvement      
    num_households_available = sum(majority_prediction_mcc(l,:) > 0);
    fprintf('%d households available in the test set more than %d weeks.\n', num_households_available, min_weeks_available);
    result(l, 2) = 100*majority_vote_accuracy;
    result(l, 5) = majority_vote_mcc;
    accuracies_majority(l) = majority_vote_accuracy;
    mccs_majority(l) = majority_vote_mcc;
end
result(end, 2) = 100 * mean(accuracies_majority);
result(end, 5) = mean(mccs_majority);

%% COMPARE OLD AND NEW
for l = 1:length(labels)+1
    result(l, 3) = result(l, 2) - result(l, 1);
    result(l, 6) = result(l, 5) - result(l, 4);
end    

%% PRINT

if ~exist(table_path, 'dir')
    mkdir(table_path);
end
fid = fopen([table_path, filename], 'w');

for l = 1:length(labels)
    fprintf(fid, '\t\\hline\n');
    if result(l, 3) >= 1.0
        arg1 = ['\textbf{+', num2str(result(l, 3), 2), '}'];
    elseif result(l, 3) < 0
        arg1 = ['-', num2str(-1*result(l, 3), 2)];
    else
        % \multicolumn{1}{c||}{-}
        arg1 = '0';
    end
    if result(l, 6) >= 0.01
        arg2 = ['\textbf{+', num2str(result(l, 6), 2), '}'];
    elseif result(l, 6) > 0
        arg2 = ['+', num2str(result(l, 6), 2)];
    elseif result(l, 6) < 0
        arg2 = ['-', num2str(-1*result(l, 6), 2)];
    else
        arg2 = '0';
    end
    fprintf(fid, '\t%s & %s & %s & %s & %s & %s & %s & %s \\\\ \n', ...
        labels_in_table{l}, ...
        num2str(num_classes(l)), ...
        [num2str(result(l, 1), 3), '\%'], ...
        [num2str(result(l, 2), 3), '\%'], ...
        arg1, ...
        num2str(result(l, 4), 3), ...
        num2str(result(l, 5), 3), ...
        arg2);
end
fprintf(fid, '\t\\hline\n');
fprintf(fid, '\t\\hline\n');
if result(end, 3) > 0
    arg1 = ['+', num2str(result(end, 3), 2)];
elseif result(end, 3) < 0
    arg1 = ['-', num2str(-1*result(end, 3), 2)];
else
    arg1 = '0';
end
if result(end, 6) > 0
    arg2 = ['+', num2str(result(end, 6), 2)];
elseif result(end, 6) < 0
    arg2 = ['-', num2str(-1*result(end, 6), 2)];
else
    arg2 = '0';
end
fprintf(fid, '\t\\textbf{%s} & & \\textbf{%s} & \\textbf{%s} & \\textbf{%s} & \\textbf{%s} & \\textbf{%s} & \\textbf{%s} \\\\ \n', ...
    'Mean', ...
    [num2str(result(end, 1), 3), '\%'], ...
    [num2str(result(end, 2), 3), '\%'], ...
    arg1, ...
    num2str(result(end, 4), 3), ...
    num2str(result(end, 5), 3), ...
    arg2);
fclose(fid);
