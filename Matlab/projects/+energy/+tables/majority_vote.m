% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function majority_vote()
	
    %% Preset Files 
	
	result_path = 'projects/+energy/results/classification_all/';
    table_path = 'projects/+energy/+tables/majority_vote/';
    
    labels = { ...
            'Singles';...
            'All_Employed';...
            'Unoccupied';...
            'Families';...
            'NoKids';...
            'eCooking';...
            'Retired';...
            'Persons';...
            'Employment';...
            'Floorarea';...
            'Age';...
            'OldHouses';...
            'HouseType';...
            'Income';...
            'LightBulbs';...
            'SocialClass';...
            'Devices';...
            'Bedrooms';...
        };

    labels_in_table = { ...
        'single';...
        'all\_employed';...
        'unoccupied';...
        'family';...
        'children';...
        'cooking';...
        'retirement';...
        '\#residents';...
        'employment';...
        'floor\_area';...
        'age\_person';...
        'age\_house';...
        'house\_type';...
        'income';...
        'lightbulbs';...
        'social\_class';...
        '\#appliances';...
        '\#bedrooms';...
    };
        
    weeks = 1:75;
    min_weeks_available = 50;
    single_week = 26;
    
    method_acc = 'lda';
    method_mcc = 'lda_undersampling';
    
    num_labels = length(labels);
    num_weeks = length(weeks);
    num_households = 10000;
    
    prediction_accuracy = zeros(num_labels, num_weeks, num_households);
    truth_accuracy = zeros(num_labels, num_households);
    prediction_mcc = zeros(num_labels, num_weeks, num_households);
    truth_mcc = zeros(num_labels, num_households);
    majority_prediction_accuracy = zeros(num_labels, num_households);
    majority_prediction_mcc = zeros(num_labels, num_households);
    
    mccs = nan(num_labels, num_weeks);
    accuracies = nan(num_labels, num_weeks);
    
    mccs_majority = zeros(1, num_labels);
    accuracies_majority = zeros(1, num_labels);
    
    if ~exist(table_path, 'dir')
        mkdir(table_path);
    end
    fid = fopen([table_path, 'majority_vote_content.tex'], 'w');
    
    %% create arrays
    for l=1:num_labels
        label = labels{l};
        fprintf('Processing characteristic %s...\n', label);
        for w = 1:num_weeks
            week = weeks(w);
            path = [ result_path, num2str(week), '/sffs/'];
            
            %% mcc
            load([path, 'sR-', label, '_mcc_', method_mcc, '.mat']);
            mccs(l, week) = mcc(sR);
            sR_households = [];
            sR_prediction = [];
            sR_truth = [];
            for f = 1:length(sR)
                sR_households = [sR_households, sR{f}.households];
                sR_prediction = [sR_prediction, sR{f}.prediction];
                sR_truth = [sR_truth, sR{f}.truth];
            end
            for h = 1:length(sR_households)
                household = sR_households(h);
                prediction_mcc(l, w, household) = sR_prediction(h);
                truth_mcc(l, household) = sR_truth(h);
            end
            
            %% accuracy
            load([path, 'sR-', label, '_accuracy_', method_acc, '.mat']);
            accuracies(l, week) = accuracy(sR);
            sR_households = [];
            sR_prediction = [];
            sR_truth = [];
            for f = 1:length(sR)
                sR_households = [sR_households, sR{f}.households];
                sR_prediction = [sR_prediction, sR{f}.prediction];
                sR_truth = [sR_truth, sR{f}.truth];
            end
            for h = 1:length(sR_households)
                household = sR_households(h);
                prediction_accuracy(l, w, household) = sR_prediction(h);
                truth_accuracy(l, household) = sR_truth(h);
            end
        end
    
        %% select households with at least 'min_weeks_available' readings and take majority vote
        for h = 1:10000
            prediction_available = find(prediction_mcc(l, :, h) > 0);
            if length(prediction_available) > min_weeks_available
                t = truth_mcc(l, h);
                p = prediction_mcc(l, prediction_available, h);
                majority_prediction_mcc(l, h) = mode(p);
            end
        end
        
        %% select households with at least 'min_weeks_available' readings and take majority vote
        for h = 1:10000
            prediction_available = find(prediction_accuracy(l, :, h) > 0);
            if length(prediction_available) > min_weeks_available
                t = truth_accuracy(l, h);
                p = prediction_accuracy(l, prediction_available, h);
                majority_prediction_accuracy(l, h) = mode(p);
            end
        end
        
        %% create confusion matrix
        C = max(truth_mcc(l, :));
        confusion_mcc = zeros(max(truth_mcc(l, :)));
        for c_row = 1:C
            for c_col = 1:C
                num = sum(truth_mcc(l, :) == c_row & majority_prediction_mcc(l, :) == c_col);
                confusion_mcc(c_row, c_col) = num;
            end
        end
    
        C = max(truth_accuracy(l, :));
        confusion_accuracy = zeros(max(truth_accuracy(l, :)));
        for c_row = 1:C
            for c_col = 1:C
                num = sum(truth_accuracy(l, :) == c_row & majority_prediction_accuracy(l, :) == c_col);
                confusion_accuracy(c_row, c_col) = num;
            end
        end
    
        %% MCC
        tmp_mccs = mccs(l,:);
        tmp_mccs = tmp_mccs(~isnan(tmp_mccs));
        mean_mcc = mean(tmp_mccs);
        majority_vote_mcc = mcc(confusion_mcc);
        
        %% Accuracy
        tmp_accuracies = accuracies(l,:);
        tmp_accuracies = tmp_accuracies(~isnan(tmp_accuracies));
        mean_accuracy = mean(tmp_accuracies);
        majority_vote_accuracy = accuracy(confusion_accuracy);
        
        %% average improvement      
        arg1 = labels_in_table{l};
        arg2 = sum(majority_prediction_mcc(l,:) > 0);
        fprintf('%d households available in the test set more than %d weeks.\n', arg2, min_weeks_available);
        arg3 = num2str(100*accuracies(l,single_week), 2);
        arg4 = num2str(mean_accuracy, 2);
        arg5 = num2str(100*majority_vote_accuracy, 2);
        arg6 = num2str(mccs(l,single_week), 2);
        arg7 = num2str(mean_mcc, 2);
        arg8 = num2str(majority_vote_mcc, 2);
        fprintf(fid, '\t\\hline\n');
        fprintf(fid, '\t%s & %s & %s & %s & %s \\\\ \n', arg1, [arg3, '\%'], [arg5, '\%'], arg6, arg8);
        
        accuracies_majority(l) = majority_vote_accuracy;
        mccs_majority(l) = majority_vote_mcc;
        
    end
    
    mcc_improvement = mccs_majority' - mccs(:, single_week);
    accuracies_improvement = accuracies_majority' - accuracies(:, single_week);
    
    fprintf('Mean of MCC majority vote improvement: %f\n', mean(mcc_improvement));
    fprintf('Mean of accuracy majority vote improvement: %f\n', mean(accuracies_improvement));

    arg1 = 'Mean';
    arg2 = num2str(100 * mean(accuracies(:, single_week)), 2);
    arg3 = num2str(100 * mean(accuracies_majority), 2);
    arg4 = num2str(mean(mccs(:, single_week)), 2);
    arg5 = num2str(mean(mccs_majority), 2);
    fprintf(fid, '\t\\hline\n');
    fprintf(fid, '\t\\hline\n');
    fprintf(fid, '\t\\textbf{%s} & \\textbf{%s} & \\textbf{%s} & \\textbf{%s} & \\textbf{%s} \\\\ \n', arg1, [arg2, '\%'], [arg3, '\%'], arg4, arg5);
    fclose(fid);
    
end
