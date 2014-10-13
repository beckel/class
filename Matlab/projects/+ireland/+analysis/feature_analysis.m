function feature_analysis()
    
feature_set_name = 'ireland.feature_set_all';

data_path = 'projects/+ireland/results/classification/14/ireland.feature_set_all/data/';
figure_path = 'projects/+ireland/images/features/';

labels = { ...
%     'Appliances';...
%     'Devices';...
%     'Bedrooms';...
%     'eCooking';...
%     'Employment';...
%     'Families';...
%     'Floorarea';...
%     'HouseType'; ...
%     'IncomeLH';...
%     'IncomeLMH';...
%     'LightBulbs';...
%     'NoKids';...
%     'OldHouses';...
%     'Persons';...
%     'Retired';...
    'Singles';...
%     'SocialClass';...
%     'Unoccupied';...
    'WaterHeating';...
    };

colors = { ...
        'k'...
        'r'...
        'b'...
        'g'...
        'm' ...
        };

for l = 1:length(labels)

    property_name = labels{l};

    %% load data
    %     label = labels{l};
    load([data_path, 'sD-', labels{l}, '.mat']);
    
    %% for each feature: create distribution
    feature_set = eval(feature_set_name);
    num_features = compose_featureset('dim', feature_set);
    for f = 1:num_features
        
        %% create empirical cumulative distribution function for each class
        ECDF = {};
        all_samples = [];
        for c = 1:length(sD.classes)
            samples = sD.samples{c}(f,:);
            [Fi, xi] = ecdf(samples);
            ECDF{c+1} = [xi'; Fi'];
            all_samples = [ all_samples sD.samples{c}(f,:) ];
        end
        all_samples = zscore(all_samples);
        [Fi, xi] = ecdf(all_samples);
        ECDF{1} = [xi'; Fi'];
        
        %% create plot
        fig = figure();
        hold on;
        for c = 1:length(sD.classes)
            tmp = ECDF{c+1};
            stairs(tmp(1,:), tmp(2,:), 'Color', colors{c+1});
        end
        tmp = ECDF{1};
        stairs(tmp(1,:), tmp(2,:), 'Color', colors{1});
    
        %% make plot nice and save
        feature_name = func2str(feature_set{f});
        title(['Feature ', int2str(f), ': ', feature_name, ' - ', property_name], 'FontSize', 14, 'Interpreter','none');
        xlabel('X');
        ylabel('Cumulative Probability');
        
        l_legend = {};
        for c = 1:length(sD.classes)
            l_legend{c} = [ sD.classes{c}, ' (', int2str(length(sD.samples{c})), ')' ];
        end
        l_legend{c+1} = [ 'All (', int2str(length(all_samples)), ')' ];
        legend(l_legend, 'Location', 'SE');
        fig = make_report_ready(fig, 'size', 'features');
        
        folder = [ figure_path, 'features/feature ', int2str(f), '/'];
        if ~exist(folder, 'dir')
            mkdir(folder)
        end
        filename = [ folder, property_name, '.png' ];
        saveas(fig, filename, 'png');
        folder = [ figure_path, 'properties/', property_name, '/' ];
        if ~exist(folder, 'dir')
            mkdir(folder)
        end
        filename = [ folder, 'feature ', int2str(f), '.png' ];
        saveas(fig, filename, 'png');
        
        close(fig);
        clear fig;
        clear Fi;
        clear xi;
        clear all_samples;
        clear ECDF;
        clear samples;
        clear tmp;
    end
    clear sD;
end
