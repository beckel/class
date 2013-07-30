function data_selection_cv(Config, class_func, feat_func)

path = [ Config.path_classification, num2str(Config.week), '/CrossValid', num2str(Config.cross_validation), '/', Config.feature_set, '/', Config.feature_selection, '/'];

%% Settings

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

connection = cer_db_get_connection();
select = 'ID';
from = 'UserProfile';
orderby = 'ID';
ids = cell(1,C);
for c = 1:C
	where = { ...
		'Type = 1', ...			% Only Residents
		constraints{c}, ...
		};
	query = query_builder(select, from, where, orderby);
	fprintf('%s\n', query);
	curs = fetch(exec(connection, query));
	ids{c} = cell2mat(curs.data);
end

close(connection);

%% Generate Samples

samples = cell(1,C);
truth = cell(1,C);

for c = 1:C
	N = length(ids{c});
    
	samples{c} = zeros(compose_featureset('dim', feat_set), N);
	truth{c} = ones(1,N) * c;

	avg_time = 0;
%     itemsToDelete = [];
    for i = 1:N
		tic;

		id = ids{c}(i);
		Consumption = get_weekly_consumption(id, 'cer_ireland');
        % number of zeros in this week
%         num_zero_sequences = strfind(Consumption.consumption(week,:),[0 0 0]);
%         if ~isempty(num_zero_sequences)
%             itemsToDelete(end+1) = i;
%         end
        samples{c}(:,i) = compose_featureset(Consumption.consumption(Config.week,:)', feat_set);

		t = toc;
		avg_time = (avg_time * (i-1) + t * 1) / i;
		eta = avg_time * (N - i);
		fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/N), i, N, seconds2str(eta));
    end
%     samples{c}(:,itemsToDelete) = [];
%     truth{c}(:,itemsToDelete) = [];
end

sD.classes = classes;
sD.samples = samples;
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
fprintf(fid, '\nSQL Constraint Statements:\n');
fprintf(fid, '----------------------------\n');
for c = 1:C
	fprintf(fid, '\t%i:\tWHERE %s\n', c, constraints{c});
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