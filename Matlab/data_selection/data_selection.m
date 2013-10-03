% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function data_selection(Config, class_func, feat_func)

fprintf('\nCollect household properties: %s\n\n', class_func('name'));

path = [ Config.path_classification, num2str(Config.weeks{1}), '/', Config.feature_set, '/'];
traces_per_household = Config.weeks;
num_traces_per_household = length(traces_per_household);
reference_traces = Config.reference_weeks;

% data set specific commands
if strcmp(Config.dataset, 'issm')
    % ISSM: load consumption
    load('consumption_questionnaires');
    read_questionnaires;
end

% Information for filename
sInfo.classes = class_func('name');
sInfo.features = Config.feature_set;

% Feature Set 
feat_set = feat_func();

% Classes
sClass = class_func();
classes = sClass.classes;
constraints = sClass.constr;
C = length(classes);

% get household ids
if strcmp(Config.dataset, 'cer_ireland')
    connection = cer_db_get_connection();
    select = 'ID';
    from = 'UserProfile';
    orderby = 'ID';
    ids = cell(1,C);
    for c = 1:C
        % Only Residents
        where = { ...
            'Type = 1', ...			
            constraints{c}, ...
            };
        query = query_builder(select, from, where, orderby);
        fprintf('%s\n', query);
        curs = fetch(exec(connection, query));
        ids{c} = cell2mat(curs.data);
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
    num_households = length(ids{c});
    N = length(ids{c}) * num_traces_per_household;
    
	samples{c} = zeros(compose_featureset('dim', feat_set), N);
    households{c} = zeros(1, N);
	truth{c} = ones(1,N) * c;

	avg_time = 0;
    itemsToDelete = [];
    for i = 1:num_households
		tic;

		id = ids{c}(i);
		Consumer = get_weekly_consumption(id, Config.dataset);
        
        % get average consumption from all weeks that count as a reference
        % (e.g., summer weeks)
        reference_avg = zeros(1,length(Consumer.consumption));
        if ~isempty(reference_traces)
            weeks_to_delete = [];
            for j = 1:length(reference_traces)
                week = reference_traces{j};
                weekly_trace = Consumer.consumption(week, :);
                if sum(weekly_trace == 0) > 4
                    weeks_to_delete(end+1) = j;
                    continue;
                end
                reference_avg = reference_avg + weekly_trace;
            end
            reference_avg = reference_avg ./ (j - length(weeks_to_delete));
        end
        
        for j = 1:num_traces_per_household
            idx = (i-1)*num_traces_per_household + j;
            week = traces_per_household{j};
            % discard trace if it contains more than 4 zeros
            weekly_trace = Consumer.consumption(week, :);
            if sum(weekly_trace == 0) > 4
                itemsToDelete(end+1) = idx;
                continue;
            end
            
            % add summer consumption as reference
            samples{c}(:,idx) = compose_featureset(weekly_trace', feat_set, reference_avg);
            households{c}(:,idx) = id;
        
        end
        
		t = toc;
		avg_time = (avg_time * (i-1) + t * 1) / i;
		eta = avg_time * (num_households - i);
		fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/num_households), i, num_households, seconds2str(eta));
    end
    samples{c}(:,itemsToDelete) = [];
    households{c}(:, itemsToDelete) = [];
    truth{c}(:,itemsToDelete) = [];
end

sD.classes = classes;
sD.samples = samples;
sD.households = households;
sD.truth = truth;

%% Store Data Struct

name = ['sD-', sInfo.classes];
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
fprintf(fid, '\nFeature Vector total dim: %i\n', compose_featureset('dim', feat_set));

fclose(fid);
