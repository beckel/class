% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function data_selection(Config, class_func)

fprintf('\nCollect household properties: %s\n\n', class_func('name'));

weeks = Config.weeks;

% data set specific commands
if strcmp(Config.dataset, 'issm')
    % ISSM: load consumption
    load('consumption_questionnaires');
    read_questionnaires;
end
        
% Information for filename
sInfo.classes = class_func('name');
sInfo.features = Config.feature_set;
sInfo.features_plus = Config.feature_set_plus;

% Feature Set 
feat_set = eval(Config.feature_set);
feat_set_plus = eval(Config.feature_set_plus);

% Classes
sClass = class_func();
classes = sClass.classes;
constraints = sClass.constr;
C = length(classes);

% regression (fill truth with values) or classification (fill truth with
% class membership)
if isfield(sClass, 'value')
    perform_regression = 1;
else
    perform_regression = 0;
end

% get household ids
if strcmp(Config.dataset, 'cer_ireland')
    connection = cer_db_get_connection();
    if perform_regression == 1
        select = ['UserProfile.id', sClass.value];
    else
        select = 'UserProfile.id';
    end
    from = 'PreTrial_Answers INNER JOIN UserProfile ON PreTrial_Answers.ID = UserProfile.ID';
    orderby = 'ID';
    ids = cell(1,C);
    cer_ids;
    for c = 1:C
        % Only Residents 
        where = { ...
%             'UserProfile.Type = 1', ...
            constraints{c}; ...
            };
        query = query_builder(select, from, where, orderby);
        fprintf('%s\n', query);
        curs = fetch(exec(connection, query));
        ids{c} = cell2mat(curs.data(:,1));
%         [ids{c}, ia, ~] = intersect(amir, intersect(ids{c}, setdiff(union(type1, type3), exclude)));
        [ids{c}, ia, ~] = intersect(ids{c}, setdiff(union(type1, type3), exclude));
        if size(curs.data, 2) == 2
            tmp = cell2mat(curs.data(:,2))';
            values{c} = tmp(ia);
        end
    end
    close(connection);
elseif strcmp(Config.dataset, 'issm')
    ids = cell(1,C);
    for c = 1:C
        read_questionnaires;
        names = sClass.constraint_names;
        constraint = constraints{c};
        % this will be needed as soon as two properties are supported - not
        % yet, though.
        for i = 1:length(names)
            single_constraint = constraint{i};
            column_name = names{i};
            column_number = find(ismember(questionnaire_columns,column_name));
            expression = [ 'idx = questionnaire_data(:,column_number) ', single_constraint];
            % filter entries with '-1'
            expression = [ expression, ' & questionnaire_data(:,column_number) > -1;'];
            eval(expression);
            ids{c} = questionnaire_data(idx);
        end
    end
end

%% Generate Samples
samples = cell(1,C);
households = cell(1, C);
truth = cell(1,C);

for c = 1:C
    N = length(ids{c});
    
    num_features_orig = compose_featureset('dim', feat_set);
    num_features_plus = compose_featureset('dim', feat_set_plus);
    num_features = num_features_orig + num_features_plus;
    
	samples{c} = zeros(num_features, N);
    
    households{c} = zeros(1, N);
	if perform_regression == 1
        truth{c} = values{c};
    else
        truth{c} = ones(1,N) * c;
    end

	avg_time = 0;
    del = [];
    for i = 1:N
		tic;

		id = ids{c}(i);
		Consumer = get_weekly_consumption(id, Config.dataset);
        
        weekly_traces = {};
        selected_weeks = {};
        for j = 1:length(weeks)
            week = weeks{j};
            % discard trace if it contains more than 4 zeros
            weekly_trace = Consumer.consumption(week, :);
            if sum(weekly_trace == 0) > 10
                continue;
            end
            weekly_traces{end+1} = weekly_trace;
            selected_weeks{end+1} = weeks{j};
        end
        
        % remove household if no trace is available
        if isempty(weekly_traces)
            del = [ del, i ];
            continue;
        end
            
        consumption.weekly_traces = weekly_traces; 
        consumption.weeks = selected_weeks;
        consumption.granularity = Config.granularity;
        consumption.id = id;

        for j = 1 : length(feat_set_plus)
            if isequal(feat_set_plus{j}, @temperature_sunrise_sunset) == 1
                load('data_selection/temperature_and_daylight_variables.mat');
                idx = find(temperature_and_daylight_variables(:,1) == id);
                samples{c}(num_features_orig+1, i) = temperature_and_daylight_variables(idx, 2);
                samples{c}(num_features_orig+2, i) = temperature_and_daylight_variables(idx, 3);
                samples{c}(num_features_orig+3, i) = temperature_and_daylight_variables(idx, 4);
            end
        end

        % compute features on consumption data
        features = compose_featureset(consumption, feat_set);
                
        % delete all samples that have NaN or Inf in one of their features
        samples{c}(1:num_features_orig,i) = features;
        households{c}(:,i) = id;

        current_features = samples{c}(:,i);
        if sum(isnan(current_features)) + sum(isinf(current_features)) > 0
            del = [ del, i ];
            continue;
        end
        
		t = toc;
		avg_time = (avg_time * (i-1) + t * 1) / i;
		eta = avg_time * (N - i);
		fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/N), i, N, seconds2str(eta));
    end
    samples{c}(:, del) = [];
    households{c}(:, del) = [];
    if perform_regression == 1
        values{c}(:,del) = [];
        sD.values = values;
    end
    truth{c}(:, del) = [];
end

% compute principal components as additional features
tmp = 0;
for j = 1 : length(feat_set_plus)
    if isequal(feat_set_plus{j}, @pca_analysis) == 1
        tmp = 1;
    end
end
if tmp == 1
    num_pca = pca_analysis('dim');
    all_samples = cell2mat(samples);
    features = all_samples(1:num_features-num_pca,:);
    X = features';
    [ ~, score ] = pca(zscore(X), 'NumComponents', num_pca);
    all_samples = [ features; score' ];
    idx = 1;
    for c = 1:C
        N = size(samples{c},2);
        start_idx = idx;
        stop_idx = idx + N - 1;
        samples{c}(num_features-(num_pca-1):num_features, :) = all_samples(num_features-(num_pca-1):num_features, start_idx : stop_idx);
        idx = idx + N;
    end
end

sD.classes = classes;
sD.samples = samples;
sD.households = households;
sD.truth = truth;

%% Store Data Struct

name = ['sD-', sInfo.classes];

if perform_regression == 1
    path = [ Config.path_regression, num2str(weeks{1}), '/'];
else
    path = [ Config.path_classification, num2str(weeks{1}), '/'];
end
if exist(path, 'dir') == 0
    mkdir(path);
end

filename = [path, name];
if (not(exist([filename, '.mat'], 'file')))
	save([filename, '.mat'], 'sD', 'sInfo');
else
	i = 1;
	filename_dupl = filename;
	filename = [filename_dupl, '-', num2str(i)];
	while (exist([filename, '.mat'], 'file'))
		i = i +1;
		filename = [filename_dupl, '-', num2str(i)];
	end
	save([filename, '.mat'], 'sD', 'sInfo');
end

%% Print Summary

fid = fopen([filename, '.txt'], 'w');
maxlength = 0;
for c = 1:length(classes)
	if (length(classes{c}) > maxlength)
		maxlength = length(classes{c});
	end
end

fprintf(fid, 'Classes:\n');
fprintf(fid, '--------\n');
for c = 1:C
	fprintf(fid, ['\t%i:\t%-', num2str(maxlength), 's\t\t%4i samples\n'], c, classes{c}, size(sD.samples{c},2));
end

fprintf(fid, '\nConstraints:\n');
fprintf(fid, '------------\n');
if strcmp(Config.dataset, 'cer_ireland')
    for c = 1:C
        fprintf(fid, '\t%i:\tWHERE %s\n', c, constraints{c});
    end
elseif strcmp(Config.dataset, 'issm')
    for c = 1:C
        % TODO: change when multiple constraints are supported
        constraint = constraints{c};
        fprintf(fid, '\t%i:\t %s %s\n', c, names{1}, constraint{1});
    end
end
    
fprintf(fid, '\nFeature Set:\n');
fprintf(fid, '--------------\n');
maxlength = 0; 
for f = 1:length(feat_set)
	if (length(func2str(feat_set{f})) > maxlength)
		maxlength = length(func2str(feat_set{f}));
	end
end
i = 1;
for f = 1:length(feat_set)
	D = feat_set{f}('dim');
	fprintf(fid, ['\t%-', num2str(maxlength), 's\tdim: %i\tIndex: %i..%i\n'], func2str(feat_set{f}), D, i, i+D-1);
	i = i + D;
end

fprintf(fid, '\nAdditional features:\n');
fprintf(fid, '---------------------\n');
for f = 1:length(feat_set_plus)
	D = feat_set_plus{f}('dim');
	fprintf(fid, ['\t%-', num2str(maxlength), 's\tdim: %i\tIndex: %i..%i\n'], func2str(feat_set_plus{f}), D, i, i+D-1);
	i = i + D;
end

fprintf(fid, '\nFeature Vector total dim: %i\n', compose_featureset('dim', feat_set) + compose_featureset('dim', feat_set_plus));

fclose(fid);
