function classification_apriori(Config, sCV, method, sInfo, featSelect, figureOfMerit)

sCV.method = method;
sCV.params = [];

path = [ Config.path_apriori, num2str(Config.week), '/', Config.feature_set, '/'];

A = length(sCV.apriori_classes);

if Config.cross_validation == 1
    % delete all samples that have NaN or Inf in one of their features
    for i = 1:numel(sCV.samples)
        samples = sCV.samples{i};
        idx = (sum(isnan(samples)) + sum(isinf(samples))) == 0;
        sCV.samples{i} = samples(:,idx);
        sCV.truth{i} = sCV.truth{i}(:,idx);
    end
    sCV.nfold = 4;
    for a = 1:A
        sCV_a = sCV;
        sCV_a.samples = sCV.samples(a,:);
        sCV_a.truth = sCV.truth(a,:);
        if strcmp(featSelect, 'sfs') == 1
            [sCR{a}, ~, sFSR{a}] = sfs_cv(sCV_a, figureOfMerit);
        elseif strcmp(featSelect, 'psfs') == 1
            sCV_a.P = 3;	% Number of branches for psfs
            [sCR{a}, ~, sFSR{a}] = psfs_cv(sCV_a, figureOfMerit);
        else
            fprintf('Error: invalid feature selection method');
            return;
        end
    end
elseif Config.cross_validation == 0
    for a = 1:A
        sCVa = sCV;
        sCVa.training_set = cell2mat(sCV.training_set(a,:));
        sCVa.test_set = cell2mat(sCV.test_set(a,:));
        sCVa.training_truth = cell2mat(sCV.training_truth(a,:));
        sCVa.test_truth = cell2mat(sCV.test_truth(a,:));

        if strcmp(featSelect, 'sfs') == 1
            [sCR{a}, ~, sFSR{a}] = sfs_nocv(sCVa, figureOfMerit);
        elseif strcmp(featSelect, 'psfs') == 1
            [sCR{a}, ~, sFSR{a}] = psfs_nocv(sCVa, figureOfMerit);
        else
            fprintf('Error: invalid feature selection method');
            return;
        end
    end
else
    fprintf('Error: cross validation not specified');
    return;
end

%% Store Result Structs

name = ['sCR-', sInfo.apriori, '_knownAprioriWhenClassifying_', sInfo.classes, '_', figureOfMerit.printShortTest(), '_', method];
filename = [path, name];
if (not(exist([filename, '.mat'], 'file')))
	save(filename, 'sCR', 'sFSR');
else
	i = 1;
	filename_dupl = filename;
	filename = [filename_dupl, '-', num2str(i)];
	while (exist([filename, '.mat'], 'file'))
		i = i +1;
		filename = [filename_dupl, '-', num2str(i)];
	end
	save(filename, 'sCR', 'sFSR');
end

% Print Summary
fid = fopen([filename, '.txt'], 'w');
fprintf(fid, 'Classes:\n');
fprintf(fid, '--------\n');
for c = 1:length(sCV.classes)
	fprintf(fid, '\t%i:\t%s\n', c, sCV.classes{c});
end
fprintf(fid, '\nClassifier:\n');
fprintf(fid, '-------------\n');
fprintf(fid, '\t%s\n', method);
for a = 1:A
	fprintf(fid, '\nA Priori Knowledge: %s:\n', sCV.apriori_classes{a});
	fprintf(fid, 'Selected Features:\n');
	fprintf(fid, '--------------\n');
	for i = 1:length(sFSR{a}.feat_best)-1
		fprintf(fid, '\t%i', sFSR{a}.feat_best(i));
	end
	fprintf(fid, '\t%i\n', sFSR{a}.feat_best(end));
    
    fprintf(fid, '\nCross validation: %s', num2str(Config.cross_validation));
    fprintf(fid, '\nFeature set: %s', num2str(Config.feature_set));
    fprintf(fid, '\nFeature selection: %s', num2str(Config.feature_selection));
    fprintf(fid, '\nFigure of merit: %s\n', figureOfMerit.printText());

	fprintf(fid, '\nResult: %.2f%%\n', figureOfMerit.evaluate(sCR{a})*100);
end
fclose(fid);