% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)
function regression(Config, sD, method, sInfo, figureOfMerit, log)

    sConfig.method = method;
    sConfig.classifier_params = Config.classifier_params;
    sConfig.property = sInfo.classes;
    sConfig.type = 'regression';
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

    % prepare folder/file for storing classification results
    path = [ Config.path_regression, num2str(Config.weeks{1}), '/', feat_select, '/'];
    name = ['sR-', sInfo.classes, '_', figureOfMerit.printShortText(), '_', method, undersampling_name];

    if ~exist(path, 'dir')
        mkdir(path);
    end
    log.setLogfile([path, name, '.log']);

    % store path/name in sCV to store intermediate results
    sD.tempfile = [path, name];

    C = length(sD.classes);
    
    % delete all samples that have NaN or Inf in one of their features
    samples = sD.samples{1};
    idx = (sum(isnan(samples)) + sum(isinf(samples))) == 0;
    sD.samples{1} = samples(:,idx);
    sD.households{1} = sD.households{1}(:,idx);
    sD.truth{1} = sD.values{1}(:,idx);
    
    
    %% Cross valication: prepare indeces for S partitions	
    S = 4; % number of folds
    inds = cell(1,S);
    % changed cross validation to separate households rather than samples
    N = size(sD.samples{1},2);
    M = ceil(N/S);
    s = RandStream('mcg16807','Seed',0);
    RandStream.setGlobalStream(s); 
    rand_inds = randperm(N);
    for s = 1:S-1
        inds{s} = rand_inds((s-1)*M +1:s*M);
    end
    inds{S} = rand_inds((S-1)*M +1:N);
    
     % s: column in inds that becomes test set
    for s = 1:S		
        %% Partition training and test sets		
        D = size(sD.samples{1}, 1);
        
        test_set = sD.samples{1}(:,inds{s});
        test_truth = sD.truth{1}(inds{s});
        test_households = sD.households{1}(inds{s});
        
        s_not = logic2ind(not(ind2logic(s,S)));
        training_set = sD.samples{1}(:,cell2mat(inds(s_not)));
        training_truth = sD.truth{1}(cell2mat(inds(s_not)));
        training_households = sD.households{1}(cell2mat(inds(s_not)));

        %% Perform regression on training set to obtain best feature set - just find best features here!
        sT = sConfig;
        sT.nfold = 3;
        sT.samples{1} = training_set;
        sT.truth{1} = training_truth;
        sT.households{1} = training_households;
        sTR{s} = sffs(sT, figureOfMerit, num_features, log);

        %% Now use original training and test set to train with selected features
        sC = sConfig;
        sC.training_truth = training_truth;
        sC.test_truth = test_truth;
        sC.households = test_households;
        sRR = [];
        f = [];
        num_features = length(sTR{s}.features);
        if sTR{s}.features == -1
            sC.training_set = training_set;
            sC.test_set = test_set;
            sRR{1} = classify_generic(sC, figureOfMerit);
            f(1) = figureOfMerit.evaluate(sRR{1});
        else
            for i = 1:num_features
                sC.training_set = training_set(sTR{s}.features(1:i),:);
                sC.test_set = test_set(sTR{s}.features(1:i),:);
                sRR{i} = classify_generic(sC, figureOfMerit);
                f(i) = figureOfMerit.evaluate(sRR{i});
            end
        end

        % choose last value from test set
        % [~, idx] = max(f);
        idx = num_features;
        sR{s} = sRR{idx};
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
    fprintf(fid, '\nRegression method:\n');
    fprintf(fid, '------------------\n');
    fprintf(fid, '\t%s\n', method);
    fprintf(fid, '\nSelected Features:\n');
    fprintf(fid, '--------------\n');
    for t = 1:length(sTR)
        if isempty(sTR{t}.features)
            fprintf(fid, '\tWARNING: ALL RUNS FAILED!\n\n');
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
    fprintf(fid, '\nCoefficient of determination: %.4f\n', rsquare(sR));
    fprintf(fid, 'Coefficient of determination (adjusted): %.4f\n', rsquare_adjusted(sR));
    fprintf(fid, 'Squared correlation coefficient: %.4f\n', squared_correlation_coefficient(sR));
    fprintf(fid, 'RMSE: %.2f\n', rmse(sR));
end
