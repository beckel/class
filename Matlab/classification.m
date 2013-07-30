function classification(Config, sCV, method, sInfo, featSelect, figureOfMerit)

sCV.method = method;
sCV.params = [];

% choose cross validation or not based in input parameter
if Config.cross_validation == 1
    % delete all samples that have NaN or Inf in one of their features
    for i = 1:length(sCV.samples)
        samples = sCV.samples{i};
        idx = (sum(isnan(samples)) + sum(isinf(samples))) == 0;
        sCV.samples{i} = samples(:,idx);
        sCV.truth{i} = sCV.truth{i}(:,idx);
    end 
    sCV.nfold = 4;
    % choose sfs or psfs (feature selection) based in input parameter
    if strcmp(featSelect, 'sfs') == 1
        [sCR, ~, sFSR] = sfs_cv(sCV, figureOfMerit);
    elseif strcmp(featSelect, 'psfs') == 1
        sCV.P = 3;	% Number of branches for psfs
        [sCR, ~, sFSR] = psfs_cv(sCV, figureOfMerit);
    else
        fprintf('Error: invalid feature selection method');
        return;
    end
elseif Config.cross_validation == 0
    % delete all samples that have NaN or Inf in one of their features
    for i = 1:length(sCV.training_set)
        samples = sCV.training_set{i};
        idx = (sum(isnan(samples)) + sum(isinf(samples))) == 0;
        sCV.training_set{i} = samples(:,idx);
        sCV.training_truth{i} = sCV.training_truth{i}(:,idx);
    end 
    for i = 1:length(sCV.test_set)
        samples = sCV.test_set{i};
        idx = (sum(isnan(samples)) + sum(isinf(samples))) == 0;
        sCV.test_set{i} = samples(:,idx);
        sCV.test_truth{i} = sCV.test_truth{i}(:,idx);
    end 
    sCV.training_set = cell2mat(sCV.training_set);
    sCV.test_set = cell2mat(sCV.test_set);
    sCV.training_truth = cell2mat(sCV.training_truth);
    sCV.test_truth = cell2mat(sCV.test_truth);
    % choose sfs or psfs (feature selection) based in input parameter
    if strcmp(featSelect, 'sfs') == 1
        [sCR, ~, sFSR] = sfs_nocv(sCV, figureOfMerit);
    elseif strcmp(featSelect, 'psfs') == 1
        sCV.P = 3;	% Number of branches for psfs
        [sCR, ~, sFSR] = psfs_nocv(sCV, figureOfMerit);
    else
        fprintf('Error: invalid feature selection method');
        return;
    end
else
    fprintf('Error: cross validation not specified');
    return;
end

%% Store Result Structs
if any(strcmp('restriction',fieldnames(sInfo)))
    path = [ Config.path_apriori, num2str(Config.week), '/', Config.feature_set, '/'];
    name = ['sCR-', sInfo.classes, '_restrictedBy_', sInfo.restriction, '_', figureOfMerit.printShortText(), '_', method];
else
    path = [ Config.path_classification, num2str(Config.week), '/', Config.feature_set, '/'];
    name = ['sCR-', sInfo.classes, '_', figureOfMerit.printShortText(), '_', method];
end

filename = [path, name]; 
if (not(exist([filename, '.mat'], 'file')))
	save([filename, '.mat'], 'sCR', 'sFSR');
else
	i = 1;
	filename_dupl = filename;
	filename = [filename_dupl, '-', num2str(i)];
	while (exist([filename, '.mat'], 'file'))
		i = i +1;
		filename = [filename_dupl, '-', num2str(i)];
	end
	save([filename, '.mat'], 'sCR', 'sFSR');
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
fprintf(fid, '\nSelected Features:\n');
fprintf(fid, '--------------\n');
for i = 1:length(sFSR.feat_best)-1
	fprintf(fid, '\t%i', sFSR.feat_best(i));
end
fprintf(fid, '\t%i\n', sFSR.feat_best(end));
fprintf(fid, '\nCross validation: %s', num2str(Config.cross_validation));
fprintf(fid, '\nFeature set: %s', num2str(Config.feature_set));
fprintf(fid, '\nFeature selection: %s', num2str(Config.feature_selection));
fprintf(fid, '\nFigure of merit: %s\n', figureOfMerit.printText());
fprintf(fid, '\nResult (%s): %.2f%%\n', figureOfMerit.printShortText(), figureOfMerit.evaluate(sCR)*100);
end
