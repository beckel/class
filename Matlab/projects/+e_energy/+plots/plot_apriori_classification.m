close all;
clearvars;

%% Preset Files 

path_classification = 'projects/+e_energy/results/classification_restricted/';
path_apriori = 'projects/+e_energy/results/apriori_knowledge/';
figure_path = 'projects/+e_energy/images/';

% only required if a priori knowledge plays a role
apriori_class_func = { ... 
%     { @apriori_age, @class_devices }, ...
%     { @apriori_age, @class_bedrooms }, ...
%     { @apriori_age, @class_employment }, ...
%     { @apriori_age, @class_floorarea }, ...
%     { @apriori_age, @class_persons }, ...
    { @apriori_age, @class_singles }, ...
%     { @apriori_age, @class_socialclass }, ...
%     { @apriori_bedrooms, @class_devices }, ...
%     { @apriori_bedrooms, @class_employment }, ...
%     { @apriori_bedrooms, @class_persons }, ...
    { @apriori_bedrooms, @class_singles }, ...
%     { @apriori_bedrooms, @class_socialclass }, ...
%     { @apriori_floorarea, @class_devices }, ...
%     { @apriori_floorarea, @class_bedrooms }, ...
%     { @apriori_floorarea, @class_employment }, ...
%     { @apriori_floorarea, @class_persons }, ...
    { @apriori_floorarea, @class_singles }, ...
%     { @apriori_floorarea, @class_socialclass }, ...
%     { @apriori_ownhouse, @class_devices }, ...
%     { @apriori_ownhouse, @class_employment }, ...
%     { @apriori_ownhouse, @class_persons }, ...
    { @apriori_ownhouse, @class_singles }, ...
%     { @apriori_ownhouse, @class_socialclass }, ...
%     { @apriori_persons, @class_devices }, ...
%     { @apriori_persons, @class_bedrooms }, ...
%     { @apriori_persons, @class_employment }, ...
%     { @apriori_persons, @class_socialclass }, ...
%     { @apriori_singles, @class_devices }, ...
%     { @apriori_singles, @class_bedrooms }, ...
%     { @apriori_singles, @class_employment }, ...
%     { @apriori_singles, @class_socialclass }, ...
%     { @apriori_socialclass, @class_devices }, ...
%     { @apriori_socialclass, @class_bedrooms }, ...
%     { @apriori_socialclass, @class_employment }, ...
%     { @apriori_socialclass, @class_persons }, ...
    { @apriori_socialclass, @class_singles }, ...
%     { @apriori_typehouse, @class_devices }, ...
%     { @apriori_typehouse, @class_employment }, ...
%     { @apriori_typehouse, @class_persons }, ...
    { @apriori_typehouse, @class_singles }, ...
%     { @apriori_typehouse, @class_socialclass }, ...
    };

method = { ...
        'knn'...
        'lda'...
        'mahal'...
        'svm'...
        };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

num_entries = length(apriori_class_func);

%% Sort results by f_1 measure, best result first
results = {};
for i = 1:num_entries

    a_name = apriori_class_func{i}{1}('name');
    c_name = apriori_class_func{i}{2}('name');        

    % determine best "old" accuracy
%     old_acc_max = 0;
%     for m = 1:length(method)
%         load([path_classification, 'sCR-', c_name, '_all_', method{m}, '.mat']);
%         old_acc = accuracy(sCR);
%         if old_acc > old_acc_max
%             old_acc_max = old_acc;
%         end
%     end 
    old_acc_max = 0;
    for m = 1:length(method)
        load([path_classification, 'sCR-', c_name, '_', a_name, '_all_', method{m}, '.mat']);
        old_acc = accuracy(sCR);
        if old_acc > old_acc_max
            old_acc_max = old_acc;
        end
    end 

    
    apriori_acc_max = [];
    for m = 1:length(method)
        load([path_apriori, 'sCR-', a_name, '_', c_name, '_all_', method{m}, '.mat']);
        load([path_apriori, 'sD-', a_name, '_', c_name, '_all.mat']);
        N = length(sCR);
        for j = 1:N
            acc = accuracy(sCR{j});
            if length(apriori_acc_max) < j || acc > apriori_acc_max(j)
                apriori_acc_max(j) = acc;
            end
        end
    end  

    labels = sD.apriori_classes;

    assert(length(apriori_acc_max) == N);

    for n=1:N
        results{end+1,1} = c_name;
        results{end,2} = a_name;
        results{end,3} = labels{n};
        results{end,4} = apriori_acc_max(n);
        results{end,5} = old_acc_max;
        results{end,6} = (apriori_acc_max(n) - old_acc_max) * 100;
        
        numSamples = 0;
        for s = 1:length(sD.classes)
            numSamples = numSamples + size(sD.samples{n,s}, 2);
        end
        results{end,7} = numSamples;
    end
end
 
header = { 'Property', 'A priori class', 'A priori label', 'Acc', 'Old Acc', 'Incr' };

%% Plot

data = sortrows(results, 1);
classes = unique(results(:,1));
num_classes = length(classes);

for i=1:num_classes
     
    fig = figure;
    hold on;

    idx = strcmp(data(:,1),classes{i}) == 1;
    class_res = data(idx,:);
     
    apriori_classes = unique(class_res(:,2));
    num_apriori_classes = length(apriori_classes);
    
    % put house type at the end of the plot 
    idx = strcmp('House_Type', apriori_classes(:,:));
    if sum(idx) > 0
        tmp = apriori_classes(end,:);
        apriori_classes(idx) = tmp;
        apriori_classes{end} = 'House_Type';
    end
    
    % plot horizontal line
    % plot([0.5 -0.5+num_apriori_classes], [class_accuracy class_accuracy], 'Color', 'k');
        
    for j=1:num_apriori_classes
        plot_x = j-0.5; 
        idx = strcmp(class_res(:,2), apriori_classes{j}) == 1;
        apriori_res = class_res(idx,:);
        apriori = cell2mat(apriori_res(:,4));

        % plot vertical line
%         minimum = min([apriori]);
%         maximum = max([apriori]);

        % plot red marker for weighted average
        num_samples = sum(cell2mat(apriori_res(:,7)));
        weightedAccuracy = 0;
        for k=1:size(apriori_res,1)
            weightedAccuracy = weightedAccuracy + apriori_res{k,4} * apriori_res{k,7} / num_samples;
        end
        plot(plot_x, weightedAccuracy, '*', 'Color', 'r');
        % plot([plot_x-0.1 plot_x+0.1], [weightedAccuracy weightedAccuracy],'-', 'Color', 'r');

        % plot a priori markers
        for k=1:size(apriori_res,1)
            plot_y = apriori_res{k,4};
            plot(plot_x, plot_y, 'x', 'Color', 'b');
            label_to_plot = apriori_res{k,3};
            if strcmp(label_to_plot, '65+') == 1
                label_to_plot = '> 65';
            elseif strcmp(label_to_plot, '<35') == 1
                label_to_plot = '< 35';
            elseif strcmp(label_to_plot, '3+') == 1
                label_to_plot = '> 3';
            elseif strcmp(label_to_plot, 'DE') == 1
                label_to_plot = 'D, E';
            elseif strcmp(label_to_plot, 'AB') == 1
                label_to_plot = 'A, B';
            elseif strcmp(label_to_plot, 'C') == 1
                label_to_plot = 'C_1, C_2';
            elseif strcmp(label_to_plot, 'Detatched') == 1
                label_to_plot = 'Detached';
            elseif strcmp(label_to_plot, 'Semi-Detatched') == 1
                label_to_plot = 'Semi-Detached';
            elseif strcmp(label_to_plot, '<180qm') == 1
                label_to_plot = '< 180 m^2';
            elseif strcmp(label_to_plot, '>180qm') == 1
                label_to_plot = '> 180 m^2';
            end
            t = text(plot_x+0.15, plot_y+0.01, [label_to_plot]);
            set(t, 'rotation', 45);
        end
        
        % plot black mark for baseline
        class_accuracy = apriori_res{1,5}; 
        plot([plot_x-0.1 plot_x+0.1], [class_accuracy class_accuracy], 'Color', 'k');
        % plot(plot_x, class_accuracy, 'x', 'Color', 'k');

    end
    
    width = 10;
    height = 6;

    fig = make_report_ready(fig, 'size', [width height], 'fontsize', 9);
   
    % replace a priori classes with label text
    idx = strcmp('Age', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = 'age_person';
    end
    idx = strcmp('Bedrooms', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = '#bedrooms';
    end
    idx = strcmp('Floorarea', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = 'floor_area';
    end
    idx = strcmp('House_Ownership', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = 'ownership';
    end
    idx = strcmp('House_Type', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = 'house_type';
    end
    idx = strcmp('Persons', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = '#residents';
    end
    idx = strcmp('Singles', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = 'single';
    end
    idx = strcmp('SocialClass', apriori_classes(:,:));
    if sum(idx) > 0
        apriori_classes{idx} = 'social_class';
    end
    
    xticklabel_rotate(0.5:1:num_apriori_classes-0.5,45,apriori_classes,'interpreter','none', 'Fontsize',9);
    set(gca, 'FontSize', 9);
    ylabel('Accuracy');
    h1 = get(gca,'ylabel');
    set(h1, 'FontSize', 9);
	set(gca, 'XGrid', 'on');
    set(gca, 'YGrid', 'on');

    y_ticks = get(gca, 'YTick'); 
    % set(gca, 'YTick', y_ticks);
    y_tick_labels = cell(1, length(y_ticks));
    for t = 1:length(y_ticks)
        y_tick_labels{t} = [num2str(y_ticks(t)*100), '%'];
    end
    set(gca, 'YTickLabel', y_tick_labels);
    
     %% Save figure
    filename = [ 'apriori_classification_', classes{i} ];
    warning off
    mkdir(figure_path);
    warning on
    saveas(fig, [figure_path, filename, '.eps'], 'psc2');

    close(fig);
end
