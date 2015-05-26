% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

%% Preset Files 

result_path = 'projects/+energy/results/classification_all/';
figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/results_all_weeks/';

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

labelsInPlot = { ...
    'single';...
    'all\_employed';...
    'unoccupied';...
    'family';...
    'children';...
    'cooking';...
    'retirement';...
    '#residents';...
    'employment';...
    'floor\_area';...
    'age\_person';...
    'age\_house';...
    'house\_type';...
    'income';...
    'lightbulbs';...
    'social\_class';...
    '#appliances';...
    '#bedrooms';...
};

weeks = 1:75;

method_accuracy = 'lda';
method_mcc = 'lda_undersampling';

width = 16; 
height = 8;
fontsize = 9;
fontname = 'Times';

num_labels = length(labels);
num_weeks = length(weeks);

accuracies = zeros(num_labels, num_weeks);
mccs = zeros(num_labels, num_weeks);

%     accuracies(2,6) = 0.5;
%     accuracies(2,35) = 0.2;
%     accuracies(10,35) = 0.8;
%     mccs(2,4) = 0.3;
%     mccs(3,66) = 0.1;
%     mccs(18,50) = 0.4;

%% create arrays
for l=1:num_labels
    label = labels{l};
    fprintf('Starting label %d...\n', l);
    for w = 1:num_weeks
        week = weeks(w);
        %% accuracy
        path = [ result_path, num2str(week), '/sffs/'];
        load([path, 'sR-', label, '_accuracy_', method_accuracy, '.mat']);
        result_acc = accuracy(sR);
        accuracies(l, w) = result_acc;

        %% mcc
        path = [ result_path, num2str(week), '/sffs/'];
        load([path, 'sR-', label, '_mcc_', method_mcc, '.mat']);
        result_mcc = mcc(sR);
        mccs(l, w) = result_mcc;
    end
end 

std_accuracy = zeros(1,18);
std_mcc = zeros(1,18);
for i = 1:length(labels)
    std_accuracy(i) = std(accuracies(i,:),1);
    std_mcc(i) = std(mccs(i,:),1);
end

%% plot

data = {accuracies, mccs};
colorbar_labels_accuracy = {'40%','50%','60%','70%','80%'};
filenames = {'results_all_weeks_accuracy', 'results_all_weeks_mcc'};

for p = 1:2
    
    fig_h = figure();
    colormap('jet');

%     h = subplot(1,2,1);
    imagesc(data{p});
    set(gca, 'YTick', 1:18);
    set(gca, 'YTickLabel', labelsInPlot);
    set(gca, 'XTick', 5:10:75);
    set(gcf,'color','w');

%     title('Accuracy', 'FontSize', fontsize, 'FontName', fontname);
%     title('MCC', 'FontSize', fontsize, 'FontName', fontname);
    % colorbar; 
    if p == 1
        c = colorbar('YTickLabel', colorbar_labels_accuracy);
    else
        c = colorbar;
    end
   
%     lines = {};
%     color = [0.5, 0.5, 0.5];
% 
%     num_labels = size(data{p}, 1);
%     num_weeks = size(data{p}, 2);
%     for i = 1:num_labels-1
%         for j = 1:num_weeks-1
%             % vertical line
%             lines{end+1} = line([j+0.5, j+0.5], [0+0.5, num_labels+0.5], 'Color', color, 'LineStyle', '-');
%             % horizontal line
%             lines{end+1} = line([0+0.5, num_weeks+0.5], [i+0.5, i+0.5], 'Color', color, 'LineStyle', '-');
%         end
%     end

    fig_h = make_report_ready(fig_h, 'size', [width height], 'fontsize', fontsize);

    if ~exist(figure_path, 'dir')
        mkdir(figure_path);
    end

    export_fig('-cmyk', '-pdf', [figure_path, filenames{p}, '.pdf']);

    close(fig_h);
end

csvwrite([figure_path, filename, '_acc.csv'], accuracies);
csvwrite([figure_path, filename, '_mcc.csv'], mccs);

