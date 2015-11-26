% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function run_experiment(config_file)

    if ~exist('config_file', 'var')
        config_file = 'config.yaml';
	fprintf('Using default config file: config.yaml\n');
    end

    fprintf('Running experiment with config file %s\n', config_file);
   
    Config = ReadYaml(config_file);
    
    class_func = Config.classes;
    
    %% Create log file
    log = Log('console', Config.log_level);
    
    %% Compute features and store results in 'results/classification'
    %% Takes a long time - comment out when not needed
    if Config.perform_data_collection == 1
        for i = 1:length(class_func) 
            data_selection(Config, str2func(class_func{i}));
        end
    end

    %% Run Classification
    if Config.perform_classification == 1
        
        % Obtain figure of merit(s) from config file and perform one
        % classification task for each.
        figure_of_merits = Config.figure_of_merit;
        for fm = figure_of_merits
            values = fm{1,1};
            name = values{1};
            method = eval(values{2}); 
            if length(values) == 2
                figureOfMerit = FigureOfMerit(name, method);
            else
                parameter = values{3};
                figureOfMerit = FigureOfMerit(name, method, parameter);
            end

            classifiers = Config.classifiers;
            for f = 1:length(class_func)
                for m = 1:length(classifiers)
                    class_function = str2func(class_func{f});
                    class_name = class_function('name');
                    data_file = [Config.path_classification, num2str(Config.weeks{1}), '/sD-', class_name, '.mat'];
                    fprintf('\nClassifying %s using %s classifier:\n\n', data_file, classifiers{m});
                    load(data_file);
                    classification(Config, sD, classifiers{m}, sInfo, figureOfMerit, log);
                end 
            end
        end
    end
    
    % perform regression
    if Config.perform_regression == 1
        
        % Obtain figure of merit(s) from config file and perform one
        % classification task for each.
        figure_of_merits = Config.figure_of_merit;
        for fm = figure_of_merits
            values = fm{1,1};
            name = values{1};
            method = eval(values{2}); 
            if length(values) == 2
                figureOfMerit = FigureOfMerit(name, method);
            else
                parameter = values{3};
                figureOfMerit = FigureOfMerit(name, method, parameter);
            end

            regression_methods = Config.regression;
            for f = 1:length(class_func)
                for m = 1:length(regression_methods)
                    regression_method = str2func(class_func{f});
                    property_name = regression_method('name');
                    data_file = [Config.path_regression, num2str(Config.weeks{1}), '/sD-', property_name, '.mat'];
                    fprintf('\nPerforming regression %s using regression method %s:\n\n', data_file, regression_methods{m});
                    load(data_file);
                    regression(Config, sD, regression_methods{m}, sInfo, figureOfMerit, log);
                end 
            end
        end
    end
end
