data_path = 'projects/+multi/data/';
input_path = 'projects/+multi/results/classification_simple/14/sffs/';
result_path = 'projects/+multi/results/pcc2/';
if ~exist(result_path, 'dir')
    mkdir(result_path);
end

%% CONFIG
method = 'bayes';
feature_set = eval('multi.feature_set_all');
feature_set_plus = eval('multi.feature_set_plus');

%% INIT
combinations = multi.get_combinations();
num_combinations = length(combinations);
num_features = compose_featureset('dim', feature_set) + compose_featureset('dim', feature_set_plus);

for c = 1:length(combinations)
    comb = combinations{c};
    labels = comb(:,2);
    num_properties = size(comb,1);

    %% get intersection of households where all properties are set
    households = zeros(1,10000);
    household_ids = zeros(1, 10000);
    samples = zeros(num_features, 10000);
    for p = 1:num_properties
        property = comb{p,1};
        load([data_path, 'sD-', property]);
        for class = 1:length(sD.classes)
            for i = 1:length(sD.households{class})
                h = sD.households{class}(i);
                households(h) = households(h) + 1;
                household_ids(h) = h;
                samples(:,h) = sD.samples{class}(:,i);
            end
        end
    end
    idc = (households == num_properties);
    household_ids = household_ids(:, idc);
    num_households = length(household_ids);
    samples = samples(:, idc);

    %% assemble training data and run classification chain
    for p = 1:num_properties
        property = comb{p,1};
        load([data_path, 'sD-', property]);
        truth = zeros(1, num_households);
        
        % prepare truth
        for h = 1:num_households
            household_id = household_ids(h);
            t = multi.get_truth_for_household(sD, household_id);
            if ismember(t, labels{p})
                truth(h) = 1;
            else
                truth(h) = 2;
            end
        end
            
        % append previous truth to samples for labels[p:end]
        if p > 1
            for p_append = 1:p-1
                property = comb{p_append, 1};
                load([data_path, 'sD-', property]);
                for h = 1:length(household_ids)
                    household_id = household_ids(h);
                    t = multi.get_truth_for_household(sD, household_id);
                    samples(num_features+p_append,h) = ismember(t, labels{p_append});
                end
            end
        end
                
        %% Now initialize classifier
        if length(sD.households{1}) < 10 || length(sD.households{2}) < 10
            continue;
        end
        
        % prepare classification parameters
        method = 'lda';
        Config.classifier_params = {{'num_features', 8}, {'undersampling', 1}};
        % PCC_{combination}.{property}
        sInfo.classes = ['PCC_', num2str(c), '.', num2str(p)];
        sInfo.features = 'multi.feature_set_all';
        sInfo.features_plus = 'multi.feature_set_plus';
        
        idc1 = truth == 1;
        idc2 = truth == 2;
        sD = [];
        sD.samples{1} = samples(:, idc1);
        sD.samples{2} = samples(:, idc2);
        sD.truth{1} = truth(:, idc1);
        sD.truth{2} = truth(:, idc2);
        sD.households{1} = household_ids(:, idc1);
        sD.households{2} = household_ids(:, idc2);
        
        sD.classes = {'label_true', 'label_false'};
        figureOfMerit = FigureOfMerit('mcc', @mcc);
        log = Log('console', 'debug');
        Config.feature_selection = 'sffs';
        Config.weeks = num2cell([14:22, 25:33]);
        Config.path_classification = result_path;
        Config.feature_set = sInfo.features;
        Config.feature_set_plus = sInfo.features_plus;
        
        classification_chain_featselect(Config, sD, method, sInfo, figureOfMerit, log, p-1);
        
    end
        

end


return;






