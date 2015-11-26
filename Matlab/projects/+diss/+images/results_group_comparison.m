% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich 2015
% Authors: Christian Beckel (beckel@inf.ethz.ch)

%% INIT
clear all;

result_path = 'projects/+diss/results/classification_weather_pca/';
figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/05_applications/household_classification/group_comparison/';
table_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/tables/05_applications/household_classification/';

width = 3.73;
height = 3.9;
linewidth = 1;
fontsize = 8;
fontname = 'Times';

labelsInPlot = { ...
    'all\_employed: yes'; ...
    'employment: employed'; ...
    'retirement: retired'; ...
    'unoccupied: yes'; ...
    'unoccupied: no'; ...
    'bedrooms: <= 3'; ...
    'floor\_area: big'; ...
    'house\_type: free'; ...
    'age\_house: old'; ...
    'cooking: electrical'; ...
    '#appliances: high'; ...
    'lightbulbs: few'; ...
    'income: high'; ...
    'social\_class: high (A/B)'; ...
    'social\_class: low: (D/E)'; ...
    'age\_person: high'; ...
    'family: family'; ...
    'children: no'; ...
    '#residents: >= 3'; ...
    'single: yes'; ...
};

labelsInTable = { ...
    'all\\_employed: yes'; ...
    'employment: employed'; ...
    'retirement: retired'; ...
    'unoccupied: yes'; ...
    'unoccupied: no'; ...
    'bedrooms: $\\leq 3$'; ...
    'floor\\_area: big'; ...
    'house\\_type: free'; ...
    'age\\_house: old'; ...
    'cooking: electrical'; ...
    '\\#appliances: high'; ...
    'lightbulbs: few'; ...
    'income: high'; ...
    'social\\_class: high (A/B)'; ...
    'social\\_class: low: (D/E)'; ...
    'age\\_person: high'; ...
    'family: family'; ...
    'children: no'; ...
    '\\#residents: $\\geq 3$'; ...
    'single: yes'; ...
};

labels = { ...
        {'All_Employed', 1}; ...
        {'Employment', 1}; ...
        {'Retired', 1}; ...
        {'Unoccupied', 1}; ...
        {'Unoccupied', 2}; ...
        {'Bedrooms', 1:2}; ...
        {'Floorarea', 3}; ...
        {'HouseType', 1}; ...
        {'OldHouses', 1}; ...
        {'eCooking', 1}; ...
        {'Devices', 3}; ...
        {'LightBulbs', 1}; ...
        {'Income', 2}; ...
        {'SocialClass', 1}; ...
        {'SocialClass', 3}; ...
        {'Age', 3}; ...
        {'Families', 1}; ...
        {'NoKids', 1}; ...
        {'Persons'; 2}; ...
        {'Singles', 1}; ...
};

target_group_share = [ ...
        1013/(1013+2409); ...
        2536/(1696+2536); ...
        1285/(1285+2947); ...
        885/(885+3347); ...
        3347/(885+3347); ...
        (404+1884)/(404+1884+1470+465); ...
        351/(232+1198+351); ...
        2189/(2189+1964); ...
        2151/(2151+2077); ...
        2960/(2960+1272); ...
        1332/(1332+1479+1421); ...
        2041/(2041+2191); ...
        997/(940+997); ...
        642/(642+1840+1593); ...
        1593/(642+1840+1593); ...
        953/(953+2819+436); ...
        1118/(1118+3114); ...
        3003/(1229+3003); ...
        2033/(2033+2199); ...
        859/(859+3373); ];
   
min_weeks_available = 25;
weeks = 1:75;
num_weeks =length(weeks);
num_labels = length(labels);
max_num_households = 10000;

method = 'lda_undersampling';
figure_of_merit = 'mcc';

     
%% GET TRUTH AND PREDICTION FOR ALL HOUSEHOLDS
prediction = zeros(num_labels, num_weeks, max_num_households);
truth = zeros(num_labels, max_num_households);
majority_prediction = zeros(num_labels, max_num_households);
truth_after_majority_vote = zeros(num_labels, max_num_households);

for l = 1:num_labels

    fprintf('Processing label %d\n', l);

    tmp = labels{l};
    label = tmp{1};
    basis = tmp{2};

    for w = 1:num_weeks
        week = weeks(w);
        path = [ result_path, num2str(week), '/sffs/'];

        load([path, 'sR-', label, '_', figure_of_merit, '_', method, '.mat']);
        % mccs(l, week) = mcc(sR);
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
            prediction(l, w, household) = sR_prediction(h);
            truth(l, household) = sR_truth(h);
        end
    end

    %% Select households with at least 'min_weeks_available' readings and take majority vote
    for h = 1:10000
        prediction_available = find(prediction(l, :, h) > 0);
        if length(prediction_available) > min_weeks_available
            p = prediction(l, prediction_available, h);
            majority_prediction(l, h) = mode(p);
            t = truth(l, h);
            truth_after_majority_vote(l, h) = t;
        end
    end
end
save('group_comparison.mat', 'majority_prediction', 'truth_after_majority_vote');


%% GET AVERAGE CONSUMPTION CURVES
 
load('avg_cons_all_users.mat');
load('group_comparison.mat');
household_ids;

consumption_of_target_group_predicted = cell(1, num_labels);
consumption_of_target_group_truth = cell(1, num_labels);
npoints = 1500;
start = 0;
stop = 3;
x_vals = start:(stop-start)/npoints:stop;
f_predicted = cell(1,num_labels);
f_truth = cell(1,num_labels);
for l = 1:num_labels
    
    % consumption of predicted group
    target_group = labels{l}{2};
    households_of_target_group_predicted = find(ismember(majority_prediction(l,:), target_group));
    idx = find(ismember(household_ids, households_of_target_group_predicted));
    consumption_of_target_group_predicted{l} = avg_cons_all_users(idx);
    
    households_of_target_group_truth = find(ismember(truth_after_majority_vote(l,:), target_group));
    idx = find(ismember(household_ids, households_of_target_group_truth));
    consumption_of_target_group_truth{l} = avg_cons_all_users(idx);
    
    [f_predicted{l},~] = ksdensity(consumption_of_target_group_predicted{l}, x_vals);
    [f_truth{l},~] = ksdensity(consumption_of_target_group_truth{l}, x_vals);
end
[f_all,~] = ksdensity(avg_cons_all_users, x_vals);

%% PLOT
for l = 1:20
    fig = figure;
    hold on;
%     npoints = 100; % default: 100
%     ksdensity(consumption_of_target_group_truth{l}, 'npoints', npoints);
%     ksdensity(consumption_of_target_group_predicted{l}, 'npoints', npoints);
    plot(x_vals, f_truth{l});
    plot(x_vals, f_predicted{l});
    plot(x_vals, f_all, 'Color', [0.3 0.3 0.3]);
%     legend({'truth', 'predicted', 'all'}, 'Location', 'NorthOutside', 'Orientation', 'horizontal');

%     str = {labelsInPlot{l}, ['(MAE = ', num2str(mae(f1,f2), 2), ')']}';
%     title(str);
    title(labelsInPlot{l});
    
    xlim([0, 1.5]);
    % ylim([0, 1]);

    set(gca, 'YGrid', 'on');
    set(gca, 'XGrid', 'on');
    % set(gca, 'XTick', [0 0.25 0.5 0.75 1]);
    % set(gca, 'YTick', [0 0.25 0.5 0.75 1]);

    set(gcf,'color','w');

    ylabel('Prob. density');
    xlabel('Mean cons. [W]');

    fig = make_report_ready(fig, 'size', [width, height, linewidth, fontsize]);

    % Save figure
    filename = ['group_comparison_', num2str(l)];
    if ~exist(figure_path)
        mkdir(figure_path);
    end

    export_fig('-cmyk', '-pdf', [figure_path, filename, '.pdf']);
    close(fig);    
end

%% PRINT MAE-only table
if ~exist(table_path, 'dir')
    mkdir(table_path);
end
fid = fopen([table_path, 'group_comparison_content.tex'], 'w');
mae_truth = zeros(1, num_labels);
mean_truth = zeros(1, num_labels);
mean_predicted = zeros(1, num_labels);
diff = zeros(1, num_labels);
for l = 1:num_labels
    mae_truth(l) = mae(f_predicted{l}, f_truth{l});
    mean_predicted(l) = mean(consumption_of_target_group_predicted{l});
    mean_truth(l) = mean(consumption_of_target_group_truth{l});
    diff(l) = mean_predicted(l) - mean_truth(l);
end
[~, sort_idx] = sort(mae_truth);
for l = 1:num_labels
    idx = sort_idx(l);
    if diff(l) > 0
        diff_text = ['+\\SI{', num2str(abs(diff(idx)), 2), '}{\\kilo\\watt}'];
    else
        diff_text = ['-\\SI{', num2str(abs(diff(idx)), 2), '}{\\kilo\\watt}'];
    end
    fprintf(fid, [labelsInTable{idx}, ' & \\SI{', num2str(mean_truth(idx), 2), '}{\\kilo\\watt} & \\SI{', num2str(mean_predicted(idx), 2), '}{\\kilo\\watt} & ', diff_text, ' & ', num2str(mae_truth(idx), 2), ' \\\\\n']);
end
mean_diff = mean(diff);
mean_mae_truth = mean(mae_truth);
fclose(fid); 

%% PRINT median table
load('avg_cons_all_users.mat');
load('group_comparison.mat');
household_ids;

if ~exist(table_path, 'dir')
    mkdir(table_path);
end
fid = fopen([table_path, 'group_comparison_top30_content.tex'], 'w');
sum_top30 = 0;
sum_bottom30 = 0;
sum_all = 0;
sum_diff_top30 = 0;
sum_diff_bottom30 = 0;
for l = 1:num_labels
    % preparation
    target_group = labels{l}{2};
    households_of_target_group_predicted = find(ismember(majority_prediction(l,:), target_group));
    households_of_target_group_truth = find(ismember(truth_after_majority_vote(l,:), target_group));
    idx_predicted = find(ismember(household_ids, households_of_target_group_predicted));
    idx_truth = find(ismember(household_ids, households_of_target_group_truth));
    cons_predicted = avg_cons_all_users(idx_predicted);
    consumption_of_target_group_predicted{l} = cons_predicted;
    cons_sorted = sort(cons_predicted);
    
    top30_threshold = cons_sorted(round(0.7*length(cons_sorted)));
    top30_idx_predicted = idx_predicted(cons_predicted > top30_threshold);
    fp = length(setdiff(top30_idx_predicted, idx_truth));
    tp = length(intersect(top30_idx_predicted, idx_truth));
    top30_fdr = fp/(fp+tp);
    sum_top30 = sum_top30 + top30_fdr;
    
    bottom30_threshold = cons_sorted(round(0.3*length(cons_sorted)));
    bottom30_idx_predicted = idx_predicted(cons_predicted < bottom30_threshold);
    fp = length(setdiff(bottom30_idx_predicted, idx_truth));
    tp = length(intersect(bottom30_idx_predicted, idx_truth));
    bottom30_fdr = fp/(fp+tp);
    sum_bottom30 = sum_bottom30 + bottom30_fdr;
    
    medium_30_idx_predicted = idx_predicted(cons_predicted > bottom30_threshold & cons_predicted < top30_threshold);
    fp = length(setdiff(medium_30_idx_predicted, idx_truth));
    tp = length(intersect(medium_30_idx_predicted, idx_truth));
    medium30_fdr = fp/(fp+tp);
    
    fp = length(setdiff(idx_predicted, idx_truth));
    tp = length(intersect(idx_predicted, idx_truth));
    all_fdr = fp/(fp+tp);
    sum_all = sum_all + all_fdr;
    sum_diff_top30 = sum_diff_top30 + abs(all_fdr - top30_fdr);
    sum_diff_bottom30 = sum_diff_bottom30 + abs(all_fdr - bottom30_fdr);
    
    fprintf(fid, [labelsInTable{l}, ' & ', num2str(top30_fdr, 2), ' & ', num2str(bottom30_fdr, 2), ' & ', num2str(all_fdr, 2), ' & ', num2str(target_group_share(l), 2), ' \\\\\n']);
end
% fprintf(fid, '\\midrule \n');
% fprintf(fid, ['Average &  &  & ', num2str(sum_all/num_labels, 2), ' & ', num2str(mean(target_group_share), 2), ' \\\\\n']);

sum_diff_top30 / num_labels
sum_diff_bottom30 / num_labels

fclose(fid); 
