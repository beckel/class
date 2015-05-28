
clear;

%% Preset Files 

result_path_half = 'projects/+diss/results/classification_weather_pca/';
result_path_hour = 'projects/+diss/results/classification_weather_pca_hourly/';
result_path_day = 'projects/+diss/results/classification_weather_pca_daily/';
result_paths = { result_path_half, result_path_hour, result_path_day};

figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/granularity/';

labels = { ...
        'Age';...
        'All_Employed';...
        'Bedrooms';...
        'Devices';...
        'eCooking';...
        'Employment';...
        'Families';...
        'Floorarea';...
        'HouseType';...
        'Income';...
        'LightBulbs';...
        'NoKids';...
        'OldHouses';...
        'Persons';...
        'Retired';...
        'Singles';...
        'SocialClass';...
        'Unoccupied';...
    };

labelsInPlot = { ...
    'age_person';...
    'all_employed';...
    '#bedrooms';...
    '#appliances';...
    'cooking';...
    'employment';...
    'family';...
    'floor_area';...
    'house_type';...
    'income';...
    'lightbulbs';...
    'children';...
    'age_house';...
    '#residents';...
    'retirement';...
    'single';...
    'social_class';...
    'unoccupied';...
};

method_acc = 'lda';
method_mcc = 'lda_undersampling';

l_legend = {'30-min'; ...
            '60-min'; ...
            'daily'; ...
           };

width = 19;
height = 9;
fontsize = 9;

weeks = 1:75;
min_weeks_available = 50;

num_labels = length(labels);
num_weeks = length(weeks);
num_households = 10000;

% (1): 30-min accuracy
% (2): 30-min mcc
% (3): 60-min accuracy
% (4): 60-min mcc
% (5): day accuracy
% (6): day MCC
result = zeros(num_labels+1, 6);

for iter = 1:3
    result_path = result_paths{iter};

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

    for l=1:num_labels
        label = labels{l};
        fprintf('Processing characteristic %s...\n', label);

        for w = 1:num_weeks
            week = weeks(w);
            path = [ result_path, num2str(week), '/sffs/'];

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
        result(l, (iter-1)*2+1) = 100*majority_vote_accuracy;
        result(l, iter*2) = majority_vote_mcc;
        accuracies_majority(l) = majority_vote_accuracy;
        mccs_majority(l) = majority_vote_mcc;
    end
    result(end, (iter-1)*2+1) = 100 * mean(accuracies_majority);
    result(end, iter*2) = mean(mccs_majority);
end

%% Plot results
filenames = {'granularity_accuracy', 'granularity_mcc'};
ylims = {[30, 85], [0.02, 0.55]};
ylabels = {'Accuracy', 'MCC'};
for p = 1:2

    fig_h = figure();
    data_to_plot = [result(:,p), result(:,p+2), result(:,p+4)];
    bar(data_to_plot, 'grouped');

%     xlim([0, (length(labels)+1)]);
    ylim(ylims{p});
    set(gca, 'YGrid', 'on');
    ylabel(ylabels{p});
    set(gcf,'color','w');

    legend(l_legend, 'Location', 'NorthOutside', 'orientation', 'horizontal'); 

    if p == 1
        y_ticks = get(gca, 'YTick');
        y_tick_labels = cell(1, length(y_ticks));
        for i = 1:length(y_ticks)
           y_tick_labels{i} = [num2str(y_ticks(i)), '%'];
        end
        set(gca, 'YTickLabel', y_tick_labels);
    end
    
    fig_h = make_report_ready(fig_h, 'size', [width height], 'fontsize', fontsize);
    xticklabel_rotate(1:length(labelsInPlot),45,labelsInPlot,'interpreter','none', 'Fontsize', fontsize);

    if p == 1
        y_ticks = get(gca, 'YTick');
        y_tick_labels = cell(1, length(y_ticks));
        for i = 1:length(y_ticks)
           y_tick_labels{i} = [num2str(y_ticks(i)), '%'];
        end
        set(gca, 'YTickLabel', y_tick_labels);
    end
    
    %% Save figure
    filename = filenames{p};
    if ~exist(figure_path, 'dir')
        mkdir(figure_path);
    end

    export_fig('-cmyk', '-pdf', [figure_path, filename, '.pdf']);

    close(fig_h);

end
%% Write table
csvwrite([figure_path, filename, '.csv'], result);
    



