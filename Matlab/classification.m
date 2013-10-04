% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function classification(Config, sCV, method, sInfo, featSelect, figureOfMerit)

sCV.method = method;
sCV.classification_type = Config.classification_type;
sCV.classifier_params = Config.classifier_params;

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
    [sCR, sFSR] = sfs(sCV, figureOfMerit);
elseif strcmp(featSelect, 'psfs') == 1
    sCV.P = 3;	% Number of branches for psfs
    [sCR, sFSR] = psfs(sCV, figureOfMerit);
elseif strcmp(featSelect, 'sffs') == 1
    num_features = 10;
    [sCR, sFSR] = sffs(sCV, figureOfMerit, num_features);
else
    fprintf('Error: invalid feature selection method');
    return;
end

%% Store Result Structs
if any(strcmp('restriction',fieldnames(sInfo)))
    path = [ Config.path_apriori, num2str(Config.weeks{1}), '/', Config.feature_set, '/', Config.feature_selection, '/'];
    name = ['sCR-', sInfo.classes, '_restrictedBy_', sInfo.restriction, '_', figureOfMerit.printShortText(), '_', method];
else
    path = [ Config.path_classification, num2str(Config.weeks{1}), '/', Config.feature_set, '/', Config.feature_selection, '/'];
    name = ['sCR-', sInfo.classes, '_', figureOfMerit.printShortText(), '_', method];
end

filename = [path, name]; 
warning off
mkdir(path);
warning on
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
if isempty(sFSR.feat_best)
    fprintf(fid, '\tWARNING: ALL CLASSIFICATIONS FAILED!\n\n');
else
    for i = 1:length(sFSR.feat_best)-1
        fprintf(fid, '\t%i', sFSR.feat_best(i));
    end
    fprintf(fid, '\t%i\n', sFSR.feat_best(end));
    fprintf(fid, '\nWeeks: %s', num2str(Config.weeks{1}));
    for i=2:length(Config.weeks)
        fprintf(fid, ', %s', num2str(Config.weeks{i}));
    end
    fprintf(fid, ';\n');
end
    
    fprintf(fid, '\nFeature set: %s', num2str(Config.feature_set));
    fprintf(fid, '\nFeature selection: %s', num2str(Config.feature_selection));
    fprintf(fid, '\nFigure of merit: %s\n', figureOfMerit.printText());
    fprintf(fid, '\nResult (%s): %.2f%%\n', figureOfMerit.printShortText(), figureOfMerit.evaluate(sCR)*100);
end
