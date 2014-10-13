function error_analysis_twoclass()
    
    result_path = 'projects/+ireland/results/classification/14/ireland.feature_set_all/sffs/';
    figure_path = 'projects/+ireland/images/errors/';

    labels = { ...
        'Appliances';...
        'Devices';...
        'Bedrooms';...
        'eCooking';...
        'Employment';...
        'Families';...
        'Floorarea';...
        'HouseType'; ...
        'IncomeLH';...
        'IncomeLMH';...
        'LightBulbs';...
        'NoKids';...
        'OldHouses';...
        'Persons';...
        'Retired';...
        'Singles';...
        'SocialClass';...
        'Unoccupied';...
        'WaterHeating';...
        };

    methods = { ...
        'lda';...
        'mahal';...
        'knn';...
        'svm';...
        'adaboost';...
        };

    % get household IDs
    connection = cer_db_get_connection();
    select = 'ID';
    from = 'UserProfile';
    orderby = 'ID';
    where = { ...
        'Type = 1', ...			
    };
    query = query_builder(select, from, where, orderby);
    fprintf('%s\n', query);
    curs = fetch(exec(connection, query));
    ids = cell2mat(curs.data);
    close(connection);
    
    error_matrix = NaN(length(ids), length(labels));
    for l = 1:length(labels)
        property_name = labels{l};

        %% find classifier with the best accuracy
        fm_max = 0;
        m_max = 0;
        for m = 1:length(methods)
            load([result_path, 'sCR-', labels{l}, '_accuracy_', methods{m}, '.mat']);
            fm = accuracy(sCR);
            if (fm > fm_max)
                fm_max = fm;
                m_max = m;
            end
        end

        %% determine error table for this classifier
        load([result_path, 'sCR-', labels{l}, '_accuracy_', methods{m_max}, '.mat']);

        % only use two-class properties
        if size(sCR{1}.confusion, 1) > 2
            continue;
        end
        
        num_results_sets = length(sCR);
        for rs = 1:num_results_sets
            results = sCR{rs};
            num_households = length(results.households);
            for h = 1:num_households
                % find index of household in error matrix
                idx = find(ids == results.households(h));
                if results.truth(h) == results.prediction(h)
                    error_matrix(idx, l) = 1;
                else
                    error_matrix(idx, l) = 0;
                end
            end
        end
    end

    accuracies = zeros(1,length(ids));
    del = [];
    for i=1:length(ids)
        tmp = error_matrix(i,:);
        x = error_matrix(i, ~isnan(tmp));
        
        %% TODO: compute accuracies and filter NaNs
        if isempty(x)
            del = [ del i ];
        end
        accuracies(i) = sum(x) / length(x);
    end
    accuracies(del) = [];
    ids(del) = [];
    
    %% CREATE ECDFs
    fig = figure();
    hist(accuracies, 11)
    title('Household prediction rate');
    xlabel('Correctly predicted properties');
    ylabel('Number of households');
    fig = make_report_ready(fig, 'size', 'features');
    if ~exist(figure_path, 'dir')
        mkdir(figure_path)
    end
    filename = [ figure_path, 'household_prediction_rate_twoclass', '.png' ];
    saveas(fig, filename, 'png');
    close(fig);
    
end

