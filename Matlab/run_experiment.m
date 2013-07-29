function run_experiment

    config_file = 'config.yaml';
    Config = ReadYaml(config_file);
    
    class_func = Config.classes;
    
    %% Compute features and store results in 'results/classification'
    %% Takes a long time - comment out when not needed
    if Config.perform_data_collection == 1
        features = eval(Config.feature_set);
        if Config.apriori == 1
            apriori_class_func = Config.apriori_classes;
            apriori_combinations = Config.apriori_combinations;
            for a = 1:length(apriori_class_func)
                for c = cell2mat(apriori_combinations{a})
                    if Config.cross_validation == 1
                        fprintf('a: %d, c: %d\n', a, c);
                        data_selection_cv_restricted(Config, str2func(class_func{c}), str2func(apriori_class_func{a}), features);
                        data_selection_cv_apriori(Config, str2func(apriori_class_func{a}), str2func(class_func{c}), features);
                    elseif Config.cross_validation == 0
                        data_selection_nocv_restricted(Config, str2func(class_func{c}), str2func(apriori_class_func{a}), features);
                        data_selection_nocv_apriori(Config, str2func(apriori_class_func{a}), str2func(class_func{c}), features);
                    end
                end
            end 
        elseif Config.apriori == 0
            for i = 1:length(class_func) 
                if Config.cross_validation == 1
                    data_selection_cv(Config, str2func(class_func{i}), features);
                elseif Config.cross_validation == 0
                    data_selection_nocv(Config, str2func(class_func{i}), features);
                end
            end
        end      
    end

    %% Run Classification
    if Config.perform_classification == 1
    classifiers = Config.classifiers;
        
        if Config.apriori == 1
            apriori_class_func = Config.apriori_classes;
            apriori_combinations = Config.apriori_combinations;
            figureOfMerit = FigureOfMerit('accuracy', @accuracy);
            if Config.figure_of_merit.f_measure == 1
                fprintf('Error: f_measure not yet supported for apriori classification');
            end
            for a = 1:length(apriori_class_func)
                for c = cell2mat(apriori_combinations{a})
                    for m = 1:length(classifiers)
                        apriori_function = str2func(apriori_class_func{a});
                        apriori_name = apriori_function('name'); 
                        class_function = str2func(class_func{c});
                        class_name = class_function('name');
                        
                        % perform classification based on "restricted" set
                        % (i.e., all households that have apriori
                        % information given). This is needed for later
                        % analysis.
                        data_file = [Config.path_apriori, num2str(Config.week), '/', Config.feature_set, '/sD-', class_name, '_restrictedBy_', apriori_name, '.mat'];
                        fprintf('\nClassifying %s using %s classifier:\n\n', data_file, classifiers{m});
                        load(data_file);
                        classification(Config, sD, classifiers{m}, sInfo, Config.feature_selection, figureOfMerit);
                        
                        % perform classification based on apriori classes
                        data_file = [Config.path_apriori, num2str(Config.week), '/', Config.feature_set, '/sD-', apriori_name, '_knownAprioriWhenClassifying_', class_name, '.mat'];
                        fprintf('\nClassifying %s using %s classifier:\n\n', data_file, classifiers{m});
                        load(data_file);
                        classification_apriori(Config, sD, classifiers{m}, sInfo, Config.feature_selection, figureOfMerit);
                    end
                end
            end
        elseif Config.figure_of_merit.accuracy == 1
            figureOfMerit = FigureOfMerit('accuracy', @accuracy);
            for f = 1:length(class_func)
                for m = 1:length(classifiers)
                    class_function = str2func(class_func{f});
                    class_name = class_function('name');
                    data_file = [Config.path_classification, num2str(Config.week), '/', Config.feature_set, '/sD-', class_name, '.mat'];
                    fprintf('\nClassifying %s using %s classifier:\n\n', data_file, classifiers{m});
                    load(data_file);
                    classification(Config, sD, classifiers{m}, sInfo, Config.feature_selection, figureOfMerit);
                end 
            end
        elseif Config.figure_of_merit.f_measure == 1
            betas = [ 0.0625 0.125 0.25 0.5 0.8 1 1.4 2 4 8 16 ];
            for beta = betas
                figureOfMerit = FigureOfMerit('f_measure', @f_measure, beta);
                for f = 1:length(class_func)
                    for m = 1:length(classifiers)
                        class_name = class_func{f}('name');
                        load([Config.path_classification, num2str(Config.week), '/', Config.feature_set, '/sD-', class_name, '.mat']);
                        classification(Config, sD, classifiers{m}, sInfo, Config.feature_selection, figureOfMerit);
                    end 
                end
            end
        end
    end
end
