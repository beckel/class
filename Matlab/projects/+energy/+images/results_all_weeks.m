% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function results_all_weeks()
	
    %% Preset Files 
	
	result_path = 'projects/+energy/results/classification_all/';
	figure_path = 'projects/+energy/+images/results_all_weeks/';

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
        'all_employed';...
        'unoccupied';...
        'family';...
        'children';...
        'cooking';...
        'retirement';...
        '#residents';...
        'employment';...
        'floor_area';...
        'age_person';...
        'age_house';...
        'house_type';...
        'income';...
        'lightbulbs';...
        'social_class';...
        '#appliances';...
        '#bedrooms';...
    };
        
    weeks = 1:75;
    
    method_accuracy = 'lda';
    method_mcc = 'lda_undersampling';
    
    width = 18; 
    height = 6;
    fontsize = 8;
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
        
    %% create heatmap
    fig_h = figure();
    h = subplot(1,2,1);
    imagesc(accuracies);
    set(gca, 'YTick', 1:18);
    set(gca, 'YTickLabel', labelsInPlot);
    set(gca, 'XTick', 5:10:75);
    title('Accuracy', 'FontSize', fontsize, 'FontName', fontname);
    
    % colorbar; 
    colorbar('YTickLabel', {'40%','50%','60%','70%','80%'});
%     y_ticks = get(gca, 'YTick');
%     y_tick_labels = cell(1, length(y_ticks));
%     for i = 1:length(y_ticks)
%        y_tick_labels{i} = [num2str(y_ticks(i)*100), '%'];
%     end
%     set(gca, 'YTickLabel', y_tick_labels);

    h = subplot(1,2,2);
    imagesc(mccs);
    set(gca, 'YTick', 1:18);
    set(gca, 'YTickLabel', {});
    set(gca, 'XTick', 5:10:75);
    title('MCC', 'FontSize', fontsize, 'FontName', fontname);
    colorbar;
    
    fig_h = make_report_ready(fig_h, 'size', [width height], 'fontsize', fontsize);
    
    %% Save figure
	filename = 'results_all_weeks';
    warning off
    mkdir(figure_path);
    warning on
    print('-depsc2', '-cmyk', '-r600', [figure_path, filename, '.eps']);
    % saveas(fig_h, [figure_path, filename, '.eps'], 'psc2');
  	saveas(fig_h, [figure_path, filename, '.png'], 'png');
  	close(fig_h);
  
    csvwrite([figure_path, filename, '_acc.csv'], accuracies);
    csvwrite([figure_path, filename, '_mcc.csv'], mccs);
    
end
