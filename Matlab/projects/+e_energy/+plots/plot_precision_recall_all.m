function plot_precision_recall_all()
	
    %% Preset Files 
	
	result_path = 'projects/+e_energy/results/classification/';
	figure_path = 'projects/+e_energy/images/';
    
    labels = { ...
		'eCooking'...
        'Employment'...
		'Families'...
		'NoKids'...
        'OldHouses'...
        'Persons'...
		'Retired'...
        'Singles'...
        'Persons'...
        'eCooking'...
        };
    
    % for all labels from [1-positive_idx] first property is detected
    positive_idx = 8;
        
plotColors = { ...
        'b'...
        'g'...
        'r'...
        'c'... 
        'm'...
        'y'...
        'k'...
        [1,0.4,0.6]...
        [0.4,0.6,1]...
        [0.6,0.1,0.4]...
    };

plotShapes = {...
        'o'...
        '<'...
        '+'...
        '*'...
        's'...
        'd'...
        'v'...
        '^'...
        'x'...
        '>'...
    };


%            g     green         o     circle             :     dotted
%            r     red           x     x-mark             -.    dashdot 
%            c     cyan          +     plus               --    dashed   
%            m     magenta       *     star             (none)  no line
%            y     yellow        s     square
%            k     black         d     diamond
%            w     white         v     triangle (down)
%                                ^     triangle (up)
%                                <     triangle (left)
%                                >     triangle (right)
%                                p     pentagram
%                                h     hexagram
                               
    method = { ...
            'knn'...
            'lda'...
            'mahal'...
            'svm'...
            }; 
    
    l_legend = {...
            'cooking (el.)'...
            'employment'...
            'family'...
            '#children = 0'...
            'age\_house (old)'...
            '#residents (\leq2)'...
            'retirement'...
            'single'...
            '#residents (\geq3)'...
            'cooking (not el.)'
            };
               
    % width = 8.8; 
    width = 8; 
    height = 7.4;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
	%% Sort results by f_1 measure, best result first
	best_results = zeros(1,length(labels));
	for i = 1:length(labels)
		f1_max = 0;
		for m = 1:length(method)
			load([result_path, 'sCR-', labels{i}, '_all_', method{m}, '.mat']);
            if i <= positive_idx
                f1 = f_measure(sCR, 1, 1); 
            else
                f1 = f_measure(sCR, 1, 2);
            end
			if (f1 > f1_max)
				f1_max = f1;
			end
		end
		best_results(i) = f1_max;
	end
	[~, idx] = sort(best_results,'descend');
	labels = labels(idx);
	l_legend = l_legend(idx);
    
    % determine accuracy for each 'bar'
    values = zeros(3, length(labels));
    description = cell(1, length(labels));
    for f = 1:length(labels)
        f1_max = 0;
        f1_all_methods = zeros(1,length(method));
		m_max = 0;
		for m = 1:length(method)
            load([result_path, 'sCR-', labels{f}, '_all_', method{m}, '.mat']);
			if idx(f) <= positive_idx
                f1 = f_measure(sCR, 1, 1);
            else
                f1 = f_measure(sCR, 1, 2);
            end
            f1_all_methods(m) = f1;
			if (f1 > f1_max)
				f1_max = f1;
				m_max = m;
			end
        end 
        
		load([result_path, 'sCR-', labels{f}, '_all_', method{m_max}, '.mat']);
		
        if idx(f) <= positive_idx
            values(1,f) = precision(sCR, 1);
            values(2,f) = recall(sCR, 1);
            values(3,f) = f_measure(sCR,1, 1);
        else
            values(1,f) = precision(sCR, 2);
            values(2,f) = recall(sCR, 2);
            values(3,f) = f_measure(sCR,1, 2);
        end
        description{1,f} = l_legend{f};
    end
   
    %% Plot results
	fig_h = figure();
    hold on;

    text_color = [0.5 0.5 0.5];
    for f_idx=0.1:0.1:0.9
        prec = 0:0.001:1;
        rec = prec*f_idx ./ (2*prec - f_idx);
        plot(prec, rec, '--', 'Color', text_color);
        text(prec(end)+0.02, rec(length(prec)-1)-0.022, ['F_{1}=', num2str(f_idx*100), '%'], 'Color', text_color);
    end
    text(prec(end)+0.02, 1-0.022, 'F_{1}=100%', 'Color', text_color);
    
    x = zeros(1,length(labels));
    for i=1:length(labels)
        x(i) = plot(values(1,i), values(2,i), plotShapes{i}, 'Color', plotColors{i});
        set(x(i), 'MarkerFaceColor', plotColors{i});
    end
  
    ylim([0.0 1]);
    xlim([0.0 1]);
   
    legend(x, l_legend, 'Location', 'SW');

	set(gca, 'YGrid', 'on');
    set(gca, 'XGrid', 'on');
    xlabel('Precision');
    ylabel('Recall');
    
    fig_h = make_report_ready(fig_h, 'size', [width height], 'fontsize', 8);

    y_ticks = get(gca, 'YTick');
    y_tick_labels = cell(1, length(y_ticks));
    for i = 1:length(y_ticks)
       y_tick_labels{i} = [num2str(y_ticks(i)*100), '%'];
    end
    set(gca, 'YTickLabel', y_tick_labels);
     
    x_ticks = [ 0, 0.2, 0.4, 0.6, 0.8, 1 ];
    x_tick_labels = cell(1, length(x_ticks));
    for i = 1:length(x_ticks)
       x_tick_labels{i} = [num2str(x_ticks(i)*100), '%'];
    end
    set(gca, 'XTickLabel', x_tick_labels);
    
    %% Save figure
	filename = 'ml_results_prec_recall';
    warning off
    mkdir(figure_path);
    warning on
    saveas(fig_h, [figure_path, filename, '.eps'], 'psc2');
	close(fig_h);

    %% Save results as matlab file
%     csvwrite([figure_path, filename, '.csv'], values);
    
end