% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function results_regression()
	
    result_path = 'projects/+energy/results/regression/26/sffs/';
    figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/results_regression/';

    labels = { ...
        'Age'; ...
        'Bedrooms';...
		'Devices';...
        'Floorarea';...
        'Income';...
		'Persons';...
    };
    
    titles = { ...
        'age\_person'; ...
        '#bedrooms'; ...
        '#appliances'; ...
        'floor\_area'; ...
        'income'; ...
        '#residents'; ...
    };
    
    width = 18;
    height = 16;
    linewidth = 1;
    fontsize = 9;
    fontname = 'Times';
    
    precision = 2;
    
    fig_h = figure();
    for l = 1:length(labels)

        load([result_path, 'sR-', labels{l}, '_rsquare_adjusted_linear.mat']);
        
        num_folds = length(sR);
        prediction = [];
        truth = [];
        for f = 1:num_folds
            prediction = [prediction, sR{f}.prediction];
            truth = [truth, sR{f}.truth];
        end
        
        h = subplot(3,2,l);
        hold on;
        switch labels{l}
            case 'Age'
                frequency = [];
                for i = 1:6
                    frequency(i) = sum(truth == i);
                end
                l_legend = {};
                l_legend{1} = '18-25';
                l_legend{2} = '26-35';
                l_legend{3} = '36-45';
                l_legend{4} = '46-55';
                l_legend{5} = '56-65';
                l_legend{6} = '>65';

                boxplot(prediction, truth, 'labels', l_legend, 'width', frequency ./ sum(frequency) .* 1.5 );                    

                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');
                
                % ylim([2, 5.2]);
                set(gca, 'YTick', 2:6);
                get(gca, 'YTickLabel')
                set(gca, 'YTickLabel', l_legend(2:6));
                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');

                ar2 = num2str(rsquare(sR), precision);
                my_rmse = num2str(rmse(sR), precision);
                title({[titles{l}], ['(RMSE=', my_rmse, ', R^2=', ar2, ')']}, 'FontSize', fontsize, 'FontName', fontname);

            case 'Bedrooms'
                frequency = [];
                for i = 1:5
                    frequency(i) = sum(truth == i);
                end
                l_legend = {};
                l_legend{1} = '1';
                l_legend{2} = '2';
                l_legend{3} = '3';
                l_legend{4} = '4';
                l_legend{5} = '5+';
%                 l_legend{1} = ['1 (', int2str(frequency(1)), ')'];
%                 l_legend{2} = ['2 (', int2str(frequency(2)), ')'];
%                 l_legend{3} = ['3 (', int2str(frequency(3)), ')'];
%                 l_legend{4} = ['4 (', int2str(frequency(4)), ')'];
%                 l_legend{5} = ['5+ (', int2str(frequency(5)), ')'];

                boxplot(prediction, truth, 'labels', l_legend, 'width', frequency ./ sum(frequency) .* 1.5 );                    

                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');

%                 ylabel('No. bedrooms (prediction)');

                ylim([2, 5.2]);
                set(gca, 'YTick', 1:5);
                get(gca, 'YTickLabel');
                set(gca, 'YTickLabel', {'1', '2', '3', '4', '5'});
                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');

                ar2 = num2str(rsquare(sR), precision);
                my_rmse = num2str(rmse(sR), precision);
                title({titles{2}, ['(RMSE=', my_rmse, ', R^2=', ar2, ')']}, 'FontSize', fontsize, 'FontName', fontname);

            case 'Devices'
%                 truth(truth > 17) = 18;
%                 truth(truth < 5) = 4;
%                 frequency = [];
%                 for i = 1:15
%                     frequency(i) = sum(truth == i+3);
%                 end
% 
%                 l_legend = {};
%                 for i = 1:13
%                     % l_legend{i+1} = [num2str(i+4), ' (', int2str(frequency(i+1)), ')'];
%                     l_legend{i+1} = [num2str(i+4)];
%                 end
%                 l_legend{1} = '4-';
%                 l_legend{15} = '18+';
% %                 l_legend{1} = ['4- (', int2str(frequency(1)), ')'];
% %                 l_legend{15} = ['18+ (', int2str(frequency(15)), ')'];
% 
%                 boxplot(prediction, truth, 'labels', l_legend, 'width', frequency ./ sum(frequency) .* 1.5 );                    
% 
%                 set(gca, 'YGrid', 'on');
%                 set(gca, 'XGrid', 'on');
%
%%                 ylabel('No. devices (prediction)');
%
%                 ar2 = num2str(rsquare(sR), precision);
%                 my_rmse = num2str(rmse(sR), precision);
%                 title({titles{3}, ['(RMSE=', my_rmse, ', R^2=', ar2, ')']}, 'FontSize', fontsize, 'FontName', fontname);

                plot(truth, prediction, 'x');
                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');
                ar2 = num2str(rsquare(sR), precision);
                my_rmse = num2str(rmse(sR), precision);
                title({titles{3}, ['(RMSE=', my_rmse, ', R^2=', ar2, ')']}, 'FontSize', fontsize, 'FontName', fontname);
                
            case 'Floorarea'
                plot(truth, prediction, 'x');

                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');

%                 ylabel('Floor area (prediction)');

                ar2 = num2str(rsquare(sR), precision);
                my_rmse = num2str(rmse(sR), precision);
                title({titles{4}, ['(RMSE=', my_rmse, ', R^2=', ar2, ')']}, 'FontSize', fontsize, 'FontName', fontname);

            case 'Income'
                frequency = [];
                for i = 1:5
                    frequency(i) = sum(truth == i);
                end

                l_legend = {};
                l_legend{1} = '<15';
                l_legend{2} = '15-30';
                l_legend{3} = '30-50';
                l_legend{4} = '50-75';
                l_legend{5} = '>75';

                boxplot(prediction, truth, 'labels', l_legend, 'width', frequency ./ sum(frequency) .* 1.5 );                    

                ylim([1 5]);
                set(gca, 'YTickLabel', l_legend);
                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');

                ar2 = num2str(rsquare(sR), precision);
                my_rmse = num2str(rmse(sR), precision);
                title({titles{5}, ['(RMSE=', my_rmse, ', R^2=', ar2, ')']}, 'FontSize', fontsize, 'FontName', fontname);

            case 'Persons' 
                truth(truth > 4) = 5;
                frequency = [];
                for i = 1:5
                    frequency(i) = sum(truth == i);
                end

                l_legend = {};
                l_legend{1} = '1';
                l_legend{2} = '2';
                l_legend{3} = '3';
                l_legend{4} = '4';
                l_legend{5} = '5+';

                boxplot(prediction, truth, 'labels', l_legend, 'width', frequency ./ sum(frequency) .* 1.5 );                    

                ylim([-1, 6]);
                set(gca, 'YTick', 0:6);
                % get(gca, 'YTickLabel')
                set(gca, 'YTickLabel', {'0', '1', '2', '3', '4', '5', '6'});
                set(gca, 'YGrid', 'on');
                set(gca, 'XGrid', 'on');

                ar2 = num2str(rsquare(sR), precision);
                my_rmse = num2str(rmse(sR), precision);
                title({titles{6}, ['(RMSE=', my_rmse, ', R^2=', ar2, ')']}, 'FontSize', fontsize, 'FontName', fontname);
        end
    end

    set(gcf,'color','w');
    
    fig_h = make_report_ready(fig_h, 'size', [width, height, linewidth, fontsize]);
    
    % Save figure
    filename = 'results_regression';
    if ~exist(figure_path, 'dir')
        mkdir(figure_path);
    end
    % print('-depsc2', '-cmyk', '-r600', [figure_path, filename, '.eps']);
    export_fig('-cmyk', '-pdf', [figure_path, filename, '.pdf']);

%     saveas(fig_h, [figure_path, filename, '.png']);
    close(fig_h);

end


