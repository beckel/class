% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function plot_classification_accuracy()
	
    %% Preset Files 
	
	result_path = 'projects/+issm/results/classification_aarau_counting_weeks/26/CrossValid1/issm.feature_set_all/psfs/';
	figure_path = 'projects/+issm/images/';

    labels = { ...
		'Absence'...
		'AllEmployed'...
		'Appliances'...
        'CoffeeMachine'...
        'Employed'...
		'Floorarea'...
        'Furnace'...
		'HoursTV'...
        'HouseType'...
        'Kids'...
		'LightBulbRatio'...
        'Lightbulbs'...
		'Singles'...
        'WashingMachine'...
        'WaterHeating'...
        };

    labelsInPlot = { ...
		'Abwesenheit'...
		'Alle berufstaetig'...
		'Zahl der Geraete'...
        'Kaffeemaschine'...
        'Berufstaetigkeit'...
		'Wohnungflaeche'...
        'Elektrisches Oefeli'...
		'Fernsehzeiten'...
        'Haustyp'...
        'Kinder'...
		'Anteil Energiesparlampen'...
        'Zahl der Gluehbirnen'...
		'Singlehaushalt'...
        'Waschmaschine'...
        'Warmwasseraufbereitung'...
    };

    method = { ...
            'knn'...
            'lda'...
            'mahal'...
            'svm'...
            };

    random_guess = 0;
    biased_random_guess = 1;
    class_with_most_samples = 0;
    
    % only plot best method. If set to zero the results of all methods are plotted.
    use_best = 1;
    
%     l_legend = {'Classification System', ...
%                 'Class with most samples', ...
%                 'Class probabilities', ...
%                 'Random decision', ...
%                };

    l_legend = {'CLASS', ...
                'Gewichteter Zufall', ...
                %'Zufall', ...
               };

    width = 22.5;
    height = 13;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
	%% Sort results, best result first
	best_results = zeros(1,length(labels));
	for i = 1:length(labels)
		fm_max = 0;
		for m = 1:length(method)
			load([result_path, 'sCR-', labels{i}, '_accuracy_', method{m}, '.mat']);
			fm = accuracy(sCR);
			if (fm > fm_max)
				fm_max = fm;
			end
		end
		best_results(i) = fm_max;
	end
	[~, idx] = sort(best_results,'descend');
	labels = labels(idx);
	labelsInPlot = labelsInPlot(idx);
    
    % determine number of bars to plot from variable settings
    num_bars = random_guess + ...
        biased_random_guess + ...
        class_with_most_samples + ...
        use_best;
    if use_best == 0
        num_bars = num_bars + length(methods);
    end
    
    % determine accuracy for each 'bar'
    fm_all = zeros(num_bars, length(labels));
	for f = 1:length(labels)
        fm_max = 0;
        fm_all_methods = zeros(1,length(method));
		m_max = 0;
		for m = 1:length(method)
			load([result_path, 'sCR-', labels{f}, '_accuracy_', method{m}, '.mat']);
			fm = accuracy(sCR);
            fm_all_methods(m) = fm;
			if (fm > fm_max)
				fm_max = fm;
				m_max = m;
			end
		end
        
		load([result_path, 'sCR-', labels{f}, '_accuracy_', method{m_max}, '.mat']);
		
        count = 1;
        if use_best == 1
            fm_all(count,f) = accuracy(sCR);
            count = count+1;
        else
            fm_all(count:count+length(methods)-1, f) = fm_all_methods(:);
            count = count+length(method);
        end
        if class_with_most_samples == 1
            fm_all(count,f) = accuracy_class_with_most_samples(sCR);
            count = count+1;
        end
        if biased_random_guess == 1
            fm_all(count,f) = accuracy_biased_random_guess(sCR);
            count = count+1; 
        end
        if random_guess == 1
            fm_all(count,f) = accuracy_random_guess(sCR);
            count = count+1;
        end
            
    end
     
    %% Plot results
	fig_h = figure();
	bar(fm_all', 'grouped');
    
    xlim([0, (length(labels)+1)]);
	ylim([0 1]);
	set(gca, 'YGrid', 'on');
	ylabel('Accuracy');
        
    legend(l_legend, 'Location', 'NorthOutside'); 
	 
%     fig_h = make_report_ready(fig_h, 'size', [width, height], 'fontsize', 9);
        
    y_ticks = get(gca, 'YTick');
    y_tick_labels = cell(1, length(y_ticks));
    for i = 1:length(y_ticks)
       y_tick_labels{i} = [num2str(y_ticks(i)*100), '%'];
    end
    set(gca, 'YTickLabel', y_tick_labels);
	
    % move y axis label closer to the axis
    ylab = get(gca,'YLabel');
    set(ylab,'Position', get(ylab, 'Position') - [-0.25 0 0]);

    fig_h = make_report_ready(fig_h, 'size', [width height], 'fontsize', 9);
    xticklabel_rotate(1:length(labelsInPlot),45,labelsInPlot,'interpreter','none', 'Fontsize', 9);
    
    set(fig_h, 'PaperUnits', 'centimeters');
	set(fig_h, 'PaperSize', [width height]);
	set(fig_h, 'PaperPosition', [0 0 width height]);
	set(fig_h, 'PaperPositionMode', 'manual');
	set(fig_h, 'Units', 'centimeters');
	set(fig_h, 'Position', get(fig_h, 'PaperPosition'));
    
    %% Save figure
	filename = 'accuracy';
    warning off
    mkdir(figure_path);
    warning on
    saveas(fig_h, [figure_path, filename, '.eps'], 'psc2');
  	close(fig_h);
	    
    %% Save results as matlab file
%     csvwrite([figure_path, filename, '.csv'], fm_all);
       
end


