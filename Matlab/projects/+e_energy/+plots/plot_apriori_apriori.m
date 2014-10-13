% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

close all;
clearvars;

%% Preset Files 

path_classification = 'projects/+e_energy/results/classification_restricted/';
path_apriori = 'projects/+e_energy/results/apriori_knowledge/';
figure_path = 'projects/+e_energy/images/';

% only required if a priori knowledge plays a role
apriori_class_func = { ... 
    { @apriori_age, @class_bedrooms }, ...
    { @apriori_age, @class_devices }, ...
    { @apriori_age, @class_employment }, ...
    { @apriori_age, @class_floorarea }, ...
    { @apriori_age, @class_persons }, ...
    { @apriori_age, @class_singles }, ...
    { @apriori_age, @class_socialclass }, ...
%     { @apriori_bedrooms, @class_devices }, ...
%     { @apriori_bedrooms, @class_employment }, ...
%     { @apriori_bedrooms, @class_persons }, ...
%     { @apriori_bedrooms, @class_singles }, ...
%     { @apriori_bedrooms, @class_socialclass }, ...
%     { @apriori_floorarea, @class_devices }, ...
%     { @apriori_floorarea, @class_bedrooms }, ...
%     { @apriori_floorarea, @class_employment }, ...
%     { @apriori_floorarea, @class_persons }, ...
%     { @apriori_floorarea, @class_singles }, ...
%     { @apriori_floorarea, @class_socialclass }, ...
%     { @apriori_ownhouse, @class_devices }, ...
%     { @apriori_ownhouse, @class_employment }, ...
%     { @apriori_ownhouse, @class_persons }, ...
%     { @apriori_ownhouse, @class_singles }, ...
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
%     { @apriori_socialclass, @class_singles }, ...
%     { @apriori_typehouse, @class_devices }, ...
%     { @apriori_typehouse, @class_employment }, ...
%     { @apriori_typehouse, @class_persons }, ...
%     { @apriori_typehouse, @class_singles }, ...
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
        if strcmp(labels{n},'65+') == 1
            labels{n} = '>65';
        end
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

width = 10;
height = 10;
    
data = sortrows(results, 2);

apriori_classes = unique(data(:,2));
num_apriori_classes = length(apriori_classes);

for a=1:num_apriori_classes

    fig = figure;
    hold on;

    idx = strcmp(data(:,2), apriori_classes{a}) == 1;
    apriori_data = data(idx,:);
        
    [ labels, sortOrder ] = unique(apriori_data(:,3));
    labels = apriori_data(sort(sortOrder),3);
    
    num_labels = length(labels);
    classes = unique(apriori_data(:,1));
    num_classes = length(classes);
 
    dataToPlot = zeros(num_labels+2, num_classes);
    dataToPlot(1,:) = cell2mat(apriori_data(1:num_labels:num_labels*num_classes,5));
    weightedAccuracy = 0;
    
    samplesPerClass = zeros(1,num_classes);
    for l=1:num_labels
        idx = strcmp(apriori_data(:,3),labels{l}) == 1;
        label_data = apriori_data(idx,:);
        dataToPlot(l+2,:) = cell2mat(label_data(:,4)); 
        numSamplesPerAprioriClass = [ l : num_labels : size(apriori_data,1) ];
        dataToPlot(2,:) = dataToPlot(2,:) + dataToPlot(l+2,:) .* cell2mat(apriori_data(numSamplesPerAprioriClass,7))';
        samplesPerClass = samplesPerClass + cell2mat(apriori_data(numSamplesPerAprioriClass,7))';
    end
    dataToPlot(2,:) = dataToPlot(2,:) ./ samplesPerClass;
        
    % adapt labels
    idx = strcmp('Devices', classes(:,:));
    if sum(idx) > 0
        classes{idx} = '#devices';
    end
    idx = strcmp('Bedrooms', classes(:,:));
    if sum(idx) > 0
        classes{idx} = '#bedrooms';
    end
    idx = strcmp('Employment', classes(:,:));
    if sum(idx) > 0
        classes{idx} = 'employment';
    end
    idx = strcmp('Floorarea', classes(:,:));
    if sum(idx) > 0
        classes{idx} = 'floor\_area';
    end
    idx = strcmp('Persons', classes(:,:));
    if sum(idx) > 0
        classes{idx} = '#residents';
    end
    idx = strcmp('Singles', classes(:,:));
    if sum(idx) > 0
        classes{idx} = 'single';
    end
    idx = strcmp('SocialClass', classes(:,:));
    if sum(idx) > 0
        classes{idx} = 'social\_class';
    end
    
    bar(dataToPlot, 'grouped');
    ylim([0.35 1]);
    y_ticks = [ 0.4 0.5 0.6 0.7 0.8 0.9 1 ];
    % get(gca, 'YTick');
    set(gca, 'YTick', y_ticks);
    y_tick_labels = cell(1, length(y_ticks));
    for i = 1:length(y_ticks)
        y_tick_labels{i} = [num2str(y_ticks(i)*100), '%'];
%        y_tick_labels{i} = num2str(y_ticks(i));
    end
    set(gca, 'YTickLabel', y_tick_labels);
    
    xlim([0.5 0.5 + num_labels+2 ]);
    
    legend(classes', 'Location', 'NorthOutside');
    fig = make_report_ready(fig, 'size', [width height], 'fontsize', 9);
	xticklabel_rotate(1:num_labels+2,45,[{'All'}, {'Avg'}, labels'],'interpreter','none', 'Fontsize',9);
    ylabel('Accuracy');
    set(gca, 'YGrid', 'on');
    
    %% Save figure
    filename = [ 'apriori_apriori_', apriori_classes{a} ];
    warning off
    mkdir(figure_path);
    warning on
    saveas(fig, [figure_path, filename, '.eps'], 'psc2');
 
    csvwrite([figure_path, filename, '.csv'], dataToPlot);

    close(fig);
end


  