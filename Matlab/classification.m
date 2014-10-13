% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function classification(Config, sD, method, sInfo, figureOfMerit, log)

% [ training set | validation set | test set ]
% [ 50%          | 25%            | 25%      ]
% [  4x CV                        |          ]
% [  3x CV       |                ]

sConfig.method = method;
sConfig.classifier_params = Config.classifier_params;
sConfig.type = 'classification';
sConfig.property = sInfo.classes;
sConfig.classes = sD.classes;

feat_select = Config.feature_selection;

for i = 1:length(sConfig.classifier_params)
    param = sConfig.classifier_params{i};
    if strcmp(param{1}, 'undersampling') == 1
        undersampling = param{2};
    elseif strcmp(param{1}, 'num_features') == 1
        num_features = param{2};
    end
end
sConfig.undersampling = undersampling;

% prepare folder/file for storing classification results
if undersampling == 1
    undersampling_name = '_undersampling';
else
    undersampling_name = '';
end
if any(strcmp('restriction',fieldnames(sInfo)))
    path = [ Config.path_apriori, num2str(Config.weeks{1}), '/', feat_select, '/'];
    name = ['sR-', sInfo.classes, '_restrictedBy_', sInfo.restriction, '_', figureOfMerit.printShortText(), '_', method, undersampling_name];
elseif Config.apriori == 1
    path = [ Config.path_apriori, num2str(Config.weeks{1}), '/', feat_select, '/'];
    name = ['sR-', sInfo.classes, '_apriori_', sInfo.apriori, '_', figureOfMerit.printShortText(), '_', method, undersampling_name];
else
    path = [ Config.path_classification, num2str(Config.weeks{1}), '/', feat_select, '/'];
    name = ['sR-', sInfo.classes, '_', figureOfMerit.printShortText(), '_', method, undersampling_name];
end
warning off
mkdir(path);
warning on
log.setLogfile([path, name, '.log']);

% store path/name in sCV to store intermediate results
sConfig.tempfile = [path, name];

C = length(sD.classes);

% delete all samples that have NaN or Inf in one of their features
for i = 1:C
    samples = sD.samples{i};
    idx = (sum(isnan(samples), 1) + sum(isinf(samples), 1)) == 0;
    sD.samples{i} = samples(:,idx);
    sD.households{i} = sD.households{i}(:,idx);
    sD.truth{i} = sD.truth{i}(:,idx);
end 

%% Cross valication: prepare indeces for S partitions	
S = 4; % number of folds
inds = cell(C,S);
for c = 1:C
    % changed cross validation to separate households rather than samples
    N = size(sD.samples{c},2);
    M = ceil(N/S);
    s = RandStream('mcg16807','Seed',0);
    RandStream.setGlobalStream(s); 
    rand_inds = randperm(N);
    for s = 1:S-1
        inds{c,s} = rand_inds((s-1)*M +1:s*M);
    end
    inds{c,S} = rand_inds((S-1)*M +1:N);
end
    
% s: column in inds that becomes test set
for s = 1:S		
    %% Partition training and test sets		
    D = size(sD.samples{1}, 1);
    N = 0;
    for c = 1:C
        N = N + length(inds{c,s});
    end
    test_set = zeros(D,N);
    test_truth = zeros(1,N);
    test_households = zeros(1,N);
    i = 1;
    for c = 1:C
        test_set(:,i:i+length(inds{c,s})-1) = sD.samples{c}(:,inds{c,s});
        test_truth(i:i+length(inds{c,s})-1) = sD.truth{c}(inds{c,s});
        test_households(i:i+length(inds{c,s})-1) = sD.households{c}(inds{c,s});
        i = i + length(inds{c,s});
    end
		
    s_not = logic2ind(not(ind2logic(s,S)));
    N = 0;
    for c = 1:C
        N = N + length(cell2mat(inds(c,s_not)));
    end
    training_set = zeros(D,N);
    training_truth = zeros(1,N);
    training_households = zeros(1,N);
    i = 1;
    for c = 1:C
        N = length(cell2mat(inds(c,s_not)));
        training_set(:,i:i+N-1) = sD.samples{c}(:,cell2mat(inds(c,s_not)));
        training_truth(i:i+N-1) = sD.truth{c}(cell2mat(inds(c,s_not)));
        training_households(i:i+N-1) = sD.households{c}(cell2mat(inds(c,s_not)));

        i = i + N;
    end

    %% Perform classification to obtain best feature set
    sT = sConfig;
    sT.nfold = 3;
    for c = 1:C
        sT.samples{c} = training_set(:, training_truth == c);
        sT.truth{c} = training_truth(training_truth == c);
        sT.households{c} = training_households(training_truth == c);
    end
        % do SFFS on training(!) but leave test - just find features here!!!
    sTR{s} = sffs(sT, figureOfMerit, num_features, log);

    %% Now use original training and test set to train with selected features
    sC = sConfig;
    sC.training_truth = training_truth;
    sC.test_truth = test_truth;
    sC.households = test_households;
    sCR = [];
    f = [];
    num_features = length(sTR{s}.features);
    if sTR{s}.features == -1
        sC.training_set = training_set;
        sC.test_set = test_set;
        sCR{1} = classify_generic(sC, figureOfMerit);
        f(1) = figureOfMerit.evaluate(sCR{1});
    else
        for i = 1:num_features
            sC.training_set = training_set(sTR{s}.features(1:i),:);
            sC.test_set = test_set(sTR{s}.features(1:i),:);
            sCR{i} = classify_generic(sC, figureOfMerit);
            f(i) = figureOfMerit.evaluate(sCR{i});
        end
    end

    % choose last value from test set
    % [~, idx] = max(f);
    idx = num_features;
    sR{s} = sCR{idx};
    sR{s}.figure_of_merits = f';
    
end

fprintf('\n');

%% Store Result Structs
filename = [path, name]; 
if (not(exist([filename, '.mat'], 'file')))
	save([filename, '.mat'], 'sR', 'sTR');
else
	i = 1;
	filename_dupl = filename;
	filename = [filename_dupl, '-', num2str(i)];
	while (exist([filename, '.mat'], 'file'))
		i = i +1;
		filename = [filename_dupl, '-', num2str(i)];
	end
	save([filename, '.mat'], 'sR', 'sTR');
end

% Print Summary
fid = fopen([filename, '.txt'], 'w');
fprintf(fid, 'Classes:\n');
fprintf(fid, '--------\n');
for c = 1:length(sD.classes)
	fprintf(fid, '\t%i:\t%s\n', c, sD.classes{c});
end 
fprintf(fid, '\nClassifier:\n');
fprintf(fid, '-------------\n');
fprintf(fid, '\t%s\n', method);
fprintf(fid, '\nSelected Features:\n');
fprintf(fid, '--------------\n');
for t = 1:length(sTR)
    if isempty(sTR{t}.features)
        fprintf(fid, '\tWARNING: ALL CLASSIFICATIONS FAILED!\n\n');
    else
        fprintf(fid, 'Fold %d: ', num2str(t));
        for i = 1:length(sTR{t}.features)-1
            fprintf(fid, '\t%i', sTR{t}.features(i));
        end
        fprintf(fid, '\t%i;\n', sTR{t}.features(end));
    end
end

fprintf(fid, '\nWeeks: %s', num2str(Config.weeks{1}));
for i=2:length(Config.weeks)
    fprintf(fid, ', %s', num2str(Config.weeks{i}));
end
    
fprintf(fid, '\nFeature set: %s', num2str(Config.feature_set));
fprintf(fid, '\nFeature set plus: %s', num2str(Config.feature_set_plus));
fprintf(fid, '\nFeature selection: %s', num2str(feat_select));
fprintf(fid, '\nFigure of merit: %s\n', figureOfMerit.printText());
fprintf(fid, '\nAccuracy: %.3f', accuracy(sR));
fprintf(fid, '\nMatthew Correlation Coefficient: %.3f\n', mcc(sR));
    
end
