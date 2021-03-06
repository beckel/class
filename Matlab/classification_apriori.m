% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function classification_apriori(Config, sCV, method, sInfo, featSelect, figureOfMerit, log)

sCV.method = method;
sCV.params = [];

path = [ Config.path_apriori, num2str(Config.weeks{1}), '/', Config.feature_set, '/', Config.feature_selection, '/'];
name = ['sCR-', sInfo.apriori, '_knownAprioriWhenClassifying_', sInfo.classes, '_', figureOfMerit.printShortText(), '_', method];
filename = [path, name];
warning off
mkdir(path);
warning on
log.setLogfile([path, name, '.log']);

A = length(sCV.apriori_classes);

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
        [sCR{a}, sFSR{a}] = sfs(sCV_a, figureOfMerit);
    elseif strcmp(featSelect, 'psfs') == 1
        sCV_a.P = 3;	% Number of branches for psfs
        [sCR{a}, sFSR{a}] = psfs(sCV_a, figureOfMerit);
    elseif strcmp(featSelect, 'sffs') == 1
        number_of_features = 5;
        [sCR{a}, sFSR{a}] = sffs(sCV_a, figureOfMerit, number_of_features);
    else
        fprintf('Error: invalid feature selection method');
        return;
    end
end

%% Store Result Structs
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
for a = 1:A
	fprintf(fid, '\nA Priori Knowledge: %s:\n', sCV.apriori_classes{a});
	fprintf(fid, 'Selected Features:\n');
	fprintf(fid, '--------------\n');
	for i = 1:length(sFSR{a}.feat_best)-1
		fprintf(fid, '\t%i', sFSR{a}.feat_best(i));
	end
	fprintf(fid, '\t%i\n', sFSR{a}.feat_best(end));
    
    fprintf(fid, '\nFeature set: %s', num2str(Config.feature_set));
    fprintf(fid, '\nFeature selection: %s', num2str(Config.feature_selection));
    fprintf(fid, '\nFigure of merit: %s\n', figureOfMerit.printText());

	fprintf(fid, '\nResult (%s): %.2f%%\n', figureOfMerit.printShortText(), figureOfMerit.evaluate(sCR{a})*100);
end
fclose(fid);
