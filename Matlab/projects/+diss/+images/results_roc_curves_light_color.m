% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich 2015
% Authors: Christian Beckel (beckel@inf.ethz.ch)

%% INIT
clear all;



result_path = 'projects/+diss/results/classification_weather_pca/';
figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/05_applications/household_classification/roc_curves/';

    
width = 7.6;
height = 7.6;
linewidth = 1;
fontsize = 8;
fontname = 'Times';

labelsInPlot = { ...
    'all\_employed: yes'; ...
    'employment: employed'; ...
    'retirement: retired'; ...
    'unoccupied: yes'; ...
    'unoccupied: no'; ...
    'bedrooms: <= 3'; ...
    'floor\_area: big'; ...
    'house\_type: free'; ...
    'age\_house: old'; ...
    'cooking: electrical'; ...
    '#appliances: high'; ...
    'lightbulbs: few'; ...
    'income: high'; ...
    'social\_class: high (A/B)'; ...
    'social\_class: low: (D/E)'; ...
    'age\_person: high'; ...
    'family: family'; ...
    'children: no'; ...
    '#residents: >= 3'; ...
    'single: yes'; ...
};

labels = { ...
        {'All_Employed', 1}; ...
        {'Employment', 1}; ...
        {'Retired', 1}; ...
        {'Unoccupied', 1}; ...
        {'Unoccupied', 2}; ...
        {'Bedrooms', 1:2}; ...
        {'Floorarea', 3}; ...
        {'HouseType', 1}; ...
        {'OldHouses', 1}; ...
        {'eCooking', 1}; ...
        {'Devices', 3}; ...
        {'LightBulbs', 1}; ...
        {'Income', 2}; ...
        {'SocialClass', 1}; ...
        {'SocialClass', 3}; ...
        {'Age', 3}; ...
        {'Families', 1}; ...
        {'NoKids', 1}; ...
        {'Persons'; 2}; ...
        {'Singles', 1}; ...
};
   
    method = 'lda_undersampling';
    figure_of_merit = 'mcc';

    markers = { ...
        'o'; ...
        '*'; ...
        '^'; ...
        'd'; ...
        's'; ...
    };

    colors = { ...
        [1 0 0];...
        [0 0 1];...
        [0 1 0];...
        [1 0 1];...
        [0 0 0];...
    };
        
    %% DATA
    
    min_false_positives = zeros(1,length(labels));
    rocs = {};
    idx = [];

    for l = 1:length(labels)
        
        fprintf('Processing label %d\n', l);

        tmp = labels{l};
        label = tmp{1};
        basis = tmp{2};
        
        % load initially to get number of classes
        load([result_path, '/1/sffs/sR-', label, '_', figure_of_merit, '_', method]);
        num_classes = size(sR{1}.posterior, 2);
        posteriors = zeros(10000, num_classes);
        truth = zeros(1, 10000);
        num_samples = zeros(1, 10000);
        for week=1:75
            path = [result_path, '/', num2str(week), '/sffs/'];
            load([path, 'sR-', label, '_', figure_of_merit, '_', method]);

            for h = 1:10000
                household_idx = [];
                iteration = 0;
                while isempty(household_idx ) && iteration < 4
                    iteration = iteration + 1;
                    household_idx  = find(sR{iteration}.households == h);
                end

                if isempty(household_idx )
                    continue;
                end

                % "household_idx" points to the index in households
                % "h" to the household number, and
                % "iteration" to the i_th elemnt in sR
                num_samples(h) = num_samples(h) + 1;
                posteriors(h,:) = posteriors(h,:) + sR{iteration}.posterior(household_idx , :);
                truth(h) = sR{iteration}.truth(household_idx );
            end
        end

        % remove househodls with 0 entries
        todelete = find(num_samples == 0);
        posteriors(todelete,:) = [];
        truth(todelete) = [];
        num_samples(todelete) = [];

        posterior = zeros(length(num_samples), num_classes);
        for i = 1:length(num_samples)
            posterior(i,:) = posteriors(i,:) ./ num_samples(i);
        end

        sR_new.posterior = posterior;
        sR_new.truth = truth;

        [ rocs{end+1}, idx(:, end+1) ] = generate_roc(sR_new, basis, method);

        % get X value where ROC touches [X, 0.5].
        element = max(find(rocs{l}(2,:) < 0.5));
        min_false_positives(l) = rocs{l}(1,element);
    end        
        
    save('rocs.mat', 'rocs', 'element', 'min_false_positives');


    %% ANALYZE
    
    load('rocs.mat');
    tpr_fifty = zeros(1,20);
    tpr_fifty_averages = 0;
    for i = 11:15
        threshold = min(find(rocs{i}(2,:) > 0.50));
        tpr_fifty(i) = rocs{i}(1, threshold);
        tpr_fifty_averages = tpr_fifty_averages + rocs{i}(1,threshold);
    end
    tpr_fifty_averages / 20
    tpr_fifty
    
    %% PLOT
    
    load('rocs.mat');
    
    colors = { ...
        GetColor([1 0 0], 70);...
        GetColor([0 0 1], 70);...
        GetColor([0 1 0], 70);...
        GetColor([1 0 1], 70);...
        [0 0 0];...
    };
        
    for l = 1:4

        fig = figure();
        hold on;

        for i = 1:5
            r = rocs{5*(l-1)+i};
%             plot(r(1,:), r(2,:), 'Color', colors{i});
            line_fewer_markers(r(1,:), r(2,:), 3, markers{i}, 'Color', colors{i}, 'MFC', colors{i}, 'markersize', 6);
        end
        
        legend(labelsInPlot{5*(l-1)+1:5*l}, 'Location', 'SouthEast');

        % plot diagonal line
        line_x =  0 : 0.01 : 1;
        line_y =  0 : 0.01 : 1;

        plot(line_x, line_y, '--', 'Color', [0.5 0.5 0.5]);

        xlim([0, 1]);
        ylim([0, 1]);

        set(gca, 'YGrid', 'on');
        set(gca, 'XGrid', 'on');
        set(gca, 'XTick', [0 0.25 0.5 0.75 1]);
        set(gca, 'YTick', [0 0.25 0.5 0.75 1]);

        set(gcf,'color','w');

        ylabel('True positive rate (recall)');
        xlabel('False positive rate');

        fig = make_report_ready(fig, 'size', [width, height, linewidth, fontsize]);

        % Save figure
        filename = ['roc_light_', num2str(l)];
        if ~exist(figure_path)
            mkdir(figure_path);
        end

        export_fig('-cmyk', '-pdf', [figure_path, filename, '.pdf']);
        close(fig);    
    end


    