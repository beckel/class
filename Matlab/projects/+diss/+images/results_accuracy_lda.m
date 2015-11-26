% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function results_accuracy_best()
	
    %% Preset Files 
	
	result_path = 'projects/+energy/results/classification/26/sffs/';
	figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/results_accuracy_best/';

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

    random_guess = 1;
    biased_random_guess = 1;
    
    % only plot best method. If set to zero the results of all methods are plotted.
    use_best = 1;
    
    l_legend = {'ACC_{CLASS}'; ...
%                 'Majority'; ...
                'ACC_{BRG}'; ...
                'ACC_{RG}'; ...
               };

%                l_legend = {'Our system'; ...
% %                 'Majority'; ...
%                 'Biased random guess'; ...
%                 'Random guess'; ...
%                };

    width = 19;
    height = 8;
    fontsize = 9;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Plot results
	fig_h = figure();
    
    fm_all = [ [81.8 78.6 76.4 73.5 72.5 71.2 73.8 75.3 72.2 52.6 59.3 63.9 61.5 60.5 56.2 52.9 56.2 38.4]/100;
        0.678769534856056,0.688343275626070,0.666132633042943,0.609895525224073,0.587137044487232,0.580137011412913,0.576268572082368,0.500681851307790,0.520255149530910,0.506011993546620,0.510108178168919,0.500168542103316,0.501343924358530,0.500473875433306,0.500409361982033,0.381210913905090,0.333892187648494,0.342212970972703
        0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.333 0.333 0.5 0.5 0.5 0.5 0.333 0.333 0.25;
        ];
    
	bar(fm_all', 'grouped');
    
    xlim([0, (length(labels)+1)]);
	ylim([0 1]);
	set(gca, 'YGrid', 'on');
	ylabel('Accuracy');
    set(gcf,'color','w');
    
    legend(l_legend, 'Location', 'NE'); 
       
    y_ticks = get(gca, 'YTick');
    y_tick_labels = cell(1, length(y_ticks));
    for i = 1:length(y_ticks)
       y_tick_labels{i} = [num2str(y_ticks(i)*200), '%'];
    end
    set(gca, 'YTickLabel', y_tick_labels);
	
    % move y axis label closer to the axis
%    ylab = get(gca,'YLabel');
%    set(ylab,'Position', get(ylab, 'Position') - [-0.25 0 0]);

    fig_h = make_report_ready(fig_h, 'size', [width height], 'fontsize', fontsize);
    xticklabel_rotate(1:length(labelsInPlot),45,labelsInPlot,'interpreter','none', 'Fontsize', fontsize);
    
%     set(fig_h, 'PaperUnits', 'centimeters');
% 	set(fig_h, 'PaperSize', [width height]);
% 	set(fig_h, 'PaperPosition', [0 0 width height]);
% 	set(fig_h, 'PaperPositionMode', 'manual');
% 	set(fig_h, 'Units', 'centimeters');
% 	set(fig_h, 'Position', get(fig_h, 'PaperPosition'));
    
    %% Save figure
	filename = 'results_accuracy_best';
    warning off
    mkdir(figure_path);
    warning on

    % print('-depsc2', '-cmyk', '-r600', [figure_path, filename, '.eps']);
    % saveas(fig_h, [figure_path, filename, '.png'], 'png');
    export_fig('-cmyk', '-pdf', [figure_path, filename, '.pdf']);

  	close(fig_h);
    
    %% Write table
    csvwrite([figure_path, filename, '.csv'], fm_all);
    
end


