% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

	
    %% Preset Files 
	figure_path = 'projects/+diss/sgc/';

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

    new_results = [81.8 78.6 76.4 73.5 72.5 71.2 73.8 75.3 72.2 52.6 59.3 63.9 61.5 60.5 56.2 52.9 56.2 38.4];
    old_results = [82 78.6 76.4 73.7 72.8 71.2 73.5 75.5 72.3 50.5 58.6 63.7 59.3 61.1 55.1 52.9 55.7 38.7];
    difference = new_results - old_results;
    
    [diff, idx] = sort(difference, 2, 'ascend');
    labelsInPlot = labelsInPlot(idx);
    
    width = 16;
    height = 16;
    fontsize = 12;
    fontname = 'Arial';
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Plot results
	fig_h = figure();
    
	% bar(difference', 'grouped');
    barh(diff);
    
%     set(gca, 'ytick', 1:18);
%     set(gca, 'yticklabel', labelsInPlot);
    set(gca,'YTickLabel',[]);
    set(gca, 'YTick', []);
    xlabel('Change in accuracy [Percentage points]');
    ylabel('Household characteristic');
    
    for i=1:9
        text(0.1, i, labelsInPlot{i});
    end
    
    for i=10:18
        text(-0.1, i, labelsInPlot{i}, 'HorizontalAlignment', 'right');
    end
        
%     
     xlim([-1.2, 2.6]);
 	 ylim([0 19]);
     set(gca, 'XGrid', 'on');
     set(gcf,'color','w');
     fig_h = make_report_ready(fig_h, 'size', [width height, 1, fontsize, 2]);

% %     set(fig_h, 'PaperUnits', 'centimeters');
% % 	set(fig_h, 'PaperSize', [width height]);
% % 	set(fig_h, 'PaperPosition', [0 0 width height]);
% % 	set(fig_h, 'PaperPositionMode', 'manual');
% % 	set(fig_h, 'Units', 'centimeters');
% % 	set(fig_h, 'Position', get(fig_h, 'PaperPosition'));
%     
%     %% Save figure
 	filename = 'change_accuracy';
    if ~exist(figure_path, 'dir')
        mkdir(figure_path);
    end
    
%     % saveas(fig_h, [figure_path, filename, '.png'], 'png');
    export_fig('-cmyk', '-pdf', [figure_path, filename, '.pdf']);
   	close(fig_h);
     
%     %% Write table
%     csvwrite([figure_path, filename, '.csv'], fm_all);
%     


