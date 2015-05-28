clearvars;

output_path = '/Users/beckel/Documents/Paper/2015-05-SmartGridComm/figures/03_household_classification/images/';
if exist(output_path, 'dir') == 0
    mkdir(output_path);
end

% plotting
width = 21.5;
height = 6;
fontsize = 8;

% run "plot_num_features" first to create feature summary
load('feature_summary.mat');

feature_names = { ...
            'c\_total', ...
            'c\_weekday', ...
            'c\_weekend', ...
            'c\_day', ...
            'c\_evening', ...
            'c\_morning', ...
            'c\_night', ...
            'c\_noon', ...
            'c\_max', ...
            'c\_min', ...
            'r\_mean/max', ...
            'r\_min/mean', ...
            'r\_morning/noon', ...
            'r\_evening/noon', ...
            'r\_noon/day', ...
            'r\_night/day', ...
            'r\_weekday/weekend', ...
            't\_above\_0.5kw', ...
            't\_above\_1kw', ...
            't\_above\_2kw', ...
            't\_above\_mean', ...
            's\_variance', ...
            's\_diff', ...
            's\_x-corr', ...
            's\_num\_peaks', ...
            'w\_sunrise', ...
            'w\_sunset', ...
            'w\_temperature', ...
};

num_features = length(feature_names);

plot_titles = {'Figure of merit: Accuracy', 'Figure of merit: MCC'};
data = {res_features_accuracy, res_features_mcc};
filenames = {'sum_features_accuracy', 'sum_features_mcc'};

for p = 1:2
    sum_features = sum(data{p}, 2);
    fig = figure;
    hold on;

    colormap = lines(5);
    colordata = zeros(1,28);
    y = NaN * ones(1, 28);
    for i = 1:28
        if ismember(i, 1:10)
            colordata(i) = 1;
        elseif ismember(i, 11:17)
            colordata(i) = 2;
        elseif ismember(i, 18:21)
            colordata(i) = 3;
        elseif ismember(i, 22:25)
            colordata(i) = 4;
        else
            colordata(i) = 5;
        end
        
        y1 = y;
        y1(i) = sum_features(i);
        bar(y1, 'FaceColor', colormap(colordata(i),:));
    end
    
%     title(plot_titles{p});
    ylabel('No. of selections');
    set(gca,'XTick',1:num_features);
    set(gca,'XTick',get(gca, 'XTick')-0.5)
    set(gca, 'Ticklength', [0 0])
    set(gcf, 'color','w');
    set(gca, 'XTickLabel',feature_names);
    set(gca, 'XTickLabelRotation', 45); 
    set(gca, 'ygrid', 'on') ;
    xlim([0, num_features+1]);

    fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
    % median
    line([0, num_features+1], [median(sum_features), median(sum_features)], 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':');
    export_fig('-cmyk', '-pdf', [output_path, filenames{p}, '.pdf']);
    csvwrite([output_path, filenames{p}, '.csv'], data{p});
    close(fig);
end

