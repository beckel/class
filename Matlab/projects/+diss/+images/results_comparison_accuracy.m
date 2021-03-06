% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function results_comparison_accuracy()
	
    %% Preset Files 
	
	result_path = 'projects/+energy/results/classification/26/sffs/';
	figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/results_comparison_accuracy/';

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
        
    methods = { ...
            'knn';...
            'lda';...
            'mahal';...
            'svm';...
            'adaboost';...
            };

    colors = { ...
            'r';...
            'b';...
            'g';...
            'm';...
            'k';...
%            [1,0.4,0.6];...
            };
        
        
    markers = { ...
            '*';...
            'p';...
            'x';...
 %           'x';...
            '+';...
        };

    l_legend = {'kNN';...
                'LDA';...
                'Mahal.';...
                'SVM';...
                'AdaBoost';...
               };

    width = 17; 
    height = 10;
    fontsize = 9;
    
    num_methods = length(methods);
    num_labels = length(labels);
    fm_all = zeros(num_methods, num_labels);
    for l = 1:num_labels
        for m = 1:length(methods)
            load([result_path, 'sR-', labels{l}, '_accuracy_', methods{m}, '.mat']);
            fm_all(m,l) = accuracy(sR);
        end
    end

    %% Plot results
	fig_h = figure();
	hold on;
    
    for l=1:num_labels
        for m=1:length(methods)-1
            tmp = plot(l, fm_all(m,l), markers{m}, 'Color', colors{m});% 'MarkerFaceColor', 'none', 'MarkerEdgeColor', colors{m});
            set(tmp, 'MarkerFaceColor', colors{m});
        end
        
        plot_x = l;
        plot_y = fm_all(length(methods),l);
        plot([plot_x-0.2 plot_x+0.2], [plot_y plot_y],'-', 'Color', colors{length(methods)});
    end
    
    hold off;
    
    xlim([0, (length(labels)+1)]);

    ylim([0.3 0.9]);
    ylabel('Accuracy');
    
    set(gcf,'color','w');
    
    set(gca, 'YGrid', 'on');
    set(gca, 'XGrid', 'on');
    
    legend(l_legend, 'Location', 'NorthOutside', 'orientation', 'horizontal');
    %legend(l_legend, 'Location', 'NE');
        
    y_ticks = [ 0.3 0.4 0.5 0.6 0.7 0.8 0.9 ];
%     set(gca, 'YTick', y_ticks);
    y_tick_labels = cell(1, length(y_ticks));
    xticklabel_rotate(1:length(labelsInPlot),45,labelsInPlot,'interpreter','none');
    for i = 1:length(y_ticks)
       y_tick_labels{i} = [num2str(y_ticks(i)*100), '%'];
    end
    set(gca, 'YTickLabel', y_tick_labels);
   
    fig_h = make_report_ready(fig_h, 'size', [width height], 'fontsize', fontsize);
        
    %% Save figure
	filename = 'results_comparison_accuracy';
    warning off
    mkdir(figure_path);
    warning on
%     print('-depsc2', '-cmyk', '-r600', [figure_path, filename, '.eps']);
    % saveas(fig_h, [figure_path, filename, '.eps'], 'psc2');
  	% saveas(fig_h, [figure_path, filename, '.png'], 'png');
    export_fig('-cmyk', '-pdf', [figure_path, filename, '.pdf']);
  	
  	close(fig_h);
    
    csvwrite([figure_path, filename, '.csv'], fm_all);
end


