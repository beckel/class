clearvars;

output_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/';
if exist(output_path, 'dir') == 0
    mkdir(output_path);
end

% plotting
width = 8.5;
height = 5;
largewidth = 17.5;
largeheight = 7;
fontsize = 9;

% run "plot_num_features" first to create feature summary
load('feature_summary.mat');

num_features = length(feature_names);

new_order = [ 1 7 8 2 3 4 5 6 9 10 11 13 15 12 14 16 17 21 22 23 25 20 18 24 19 26 27 28];
res_features_accuracy = res_features_accuracy(new_order,:);
res_features_mcc = res_features_mcc(new_order,:);
feature_names = feature_names(new_order);

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

    fig = make_report_ready(fig, 'size', [largewidth, largeheight], 'fontsize', fontsize);
    % median
    line([0, num_features+1], [median(sum_features), median(sum_features)], 'Color', 'k', 'LineWidth', 2, 'LineStyle', ':');
    export_fig('-cmyk', '-pdf', [output_path, filenames{p}, '.pdf']);
    close(fig);
end

