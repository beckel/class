data_path = 'projects/+multi/data/';
result_path = 'projects/+multi/results/power_set/';
if ~exist(result_path, 'dir')
    mkdir(result_path);
end

%% CONFIG
% method = 'lda';
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
                household_ids(1, h) = h;
                samples(:,h) = sD.samples{class}(:,i);
            end
        end
    end
    idc = (households == num_properties);
    household_ids = household_ids(:, idc);
    num_households = length(household_ids);
    samples = samples(:, idc);

    %% assemble training data and run classification chain
    truth = zeros(num_properties, num_households);
    for p = 1:num_properties    
        property = comb{p,1};
        load([data_path, 'sD-', property]);
        
        % prepare truth
        for h = 1:num_households
            household_id = household_ids(h);
            t = multi.get_truth_for_household(sD, household_id);
            if ismember(t, labels{p})
                truth(p,h) = 1;
            else
                truth(p,h) = 2;
            end
        end
    end

    % prepare classification parameters
    method = 'lda';
    Config.classifier_params = {{'num_features', 8}, {'undersampling', 1}};
    sInfo.classes = ['PS_', num2str(c)];
    sInfo.features = 'multi.feature_set_all';
    sInfo.features_plus = 'multi.feature_set_plus';

    % prepare samples and classes
    sD = [];
    sD.classes = {};
    sD.households = {};
    num_classes = 2^num_properties;
    for i = 1:num_classes
        t = de2bi(i-1, 'left-msb', num_properties);
        t(t==0) = 2;
        idc = [];
        for j = 1:num_households
            hit = sum(truth(:,j) == t');
            if hit == num_properties
                idc(end+1) = j;
            end
        end
        sD.samples{i} = samples(:, idc);
        sD.truth{i} = ones(1, length(idc)) * i;
        sD.households{i} = household_ids(:, idc);
        sD.classes{end+1} = num2str(t);
    end
     
    %% Now initialize classifier
    
    % delete the ones that have only few examples - except the last one
    % that is needed as it is the combination in question [ 1 1 ... 1 ]
    del = [];
    for i = 1:length(sD.households)-1
        if length(sD.households{i}) < 20 
            del = [ del i ];
        end
    end
    sD.samples(del) = [];
    sD.truth(del) = [];
    sD.households(del) = [];
    sD.classes(del) = [];
    if length(sD.households{end}) < 20
        continue;
    end
    
    figureOfMerit = FigureOfMerit('mcc', @mcc);
    log = Log('console', 'debug');
    Config.feature_selection = 'sffs';
    Config.weeks = num2cell([14:22, 25:33]);
    Config.path_classification = result_path;
    Config.feature_set = sInfo.features;
    Config.feature_set_plus = sInfo.features_plus;

    classification(Config, sD, method, sInfo, figureOfMerit, log);


end


return;






