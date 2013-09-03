% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function data_selection_nocv_apriori(Config, apriori_class_func, class_func, feat_func)

path = [ Config.path_apriori, num2str(Config.weeks{1}), '/CrossValid', num2str(Config.cross_validation), '/', Config.feature_set, '/'];

%% Settings

% Information for filename
sInfo.apriori = apriori_class_func('name');
sInfo.classes = class_func('name');
sInfo.features = Config.feature_set;

% Feature Set
feat_set = feat_func();

% A Priori Classes
sApriori = apriori_class_func();
A = length(sApriori.classes);

% Classes
sClass = class_func();
classes = sClass.classes;
constraints = sClass.constr;
C = length(classes);

% Prepare MySQL Connection
connection = cer_db_get_connection();
select = 'ID';
from = 'UserProfile';
orderby = 'ID';

% Prepare indeces of consumers
ids = cell(A,C);
for a = 1:A
	for c = 1:C
		where = { ...
			'Type = 1', ...			% Only Residents
			sApriori.constr{a}, ...
			constraints{c}, ...
			};
		query = query_builder(select, from, where, orderby);
		fprintf('%s\n', query);
		curs = fetch(exec(connection, query));
		ids{a,c} = cell2mat(curs.data);
	end
end

close(connection);

%% Generate Samples

training_set = cell(A,C);
training_truth = cell(A,C);
test_set = cell(A,C);
test_truth = cell(A,C);

for a = 1:A
	for c = 1:C
		[training_set{a,c}, test_set{a,c}] = collect_feature_vectors_nocv(feat_set, ids{a,c}, Config.weeks{1});
		training_truth{a,c} = ones(1,size(training_set{a,c},2)) * c;
		test_truth{a,c} = ones(1,size(test_set{a,c},2)) * c;
	end
end

sD.classes = classes;
sD.apriori_classes = sApriori.classes;
sD.training_set = training_set;
sD.test_set = test_set;
sD.training_truth = training_truth;
sD.test_truth = test_truth;

%% Store Data Struct

name = ['sD-', sInfo.apriori, '_knownAprioriWhenClassifying_', sInfo.classes];
filename = [path, name];
warning off
mkdir(path);
warning on
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
fprintf(fid, 'Subset Classes:\n');
fprintf(fid, '--------\n');
for a = 1:A
	fprintf(fid, '\t%s - %s:\n', apriori_class_func('name'), sApriori.classes{a});
	for c = 1:C
		fprintf(fid, ['\t%i:\t%-', num2str(maxlength), 's\t\t%4i training, %6i test\n'], c, classes{c}, size(sD.training_set{a,c},2), size(sD.test_set{a,c},2));
	end
end
fprintf(fid, '\nSQL Constraints Apriori Knowledge:\n');
fprintf(fid, '----------------------------\n');
for a = 1:A
	fprintf(fid, '\t%i:\tWHERE %s\n', a, sApriori.constr{a});
end
fprintf(fid, '\nSQL Constraints Classes:\n');
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
fclose(fid);
end