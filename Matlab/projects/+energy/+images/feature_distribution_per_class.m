function feature_distribution_per_class()
    
feature_set_name = 'energy.feature_set_all';
feature_set_plus_name = 'energy.feature_set_plus';

fontsize = 8;

data_path = 'projects/+energy/results/classification/26/';
figure_path = 'projects/+energy/+images/feature_distribution_per_class/';

if ~exist(figure_path, 'dir')
    mkdir(figure_path);
end


labels = { ...
%     'Appliances';...
%     'Devices';...
%     'Bedrooms';...
%     'eCooking';...
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
    'Singles';...
%    'Employment';...
%     'SocialClass';...
%     'Unoccupied';...
%     'WaterHeating';...
    };

colors = { ...
        'k'...
        'r'...
        'b'...
        'g'...
        'm' ...
        };

% NEW: c_total instead of r_noon/day
% f = [1, 14];
f = [1, 14];

fig = figure();
for l = 1:length(labels)

    property_name = labels{l};

    %% load data
    load([data_path, 'sD-', labels{l}, '.mat']);
    
    if strcmp(labels{l}, 'Singles')
        sD.classes{1} = 'Single';
        sD.classes{2} = 'No single';
     elseif strcmp(labels{l}, 'Employment')
         sD.classes{1} = 'Employed';
         sD.classes{2} = 'Not employed';
    end
    
    %% create empirical cumulative distribution function for each class
    ECDF = {};
    all_samples = [];
    for c = 1:length(sD.classes)
        samples = sD.samples{c}(f(l),:);
        if f(l) == 1
            samples = samples .* samples;
        elseif f(l) == 14
            samples = samples .* samples;
        end
            
        [Fi, xi] = ecdf(samples);
        ECDF{c+1} = [xi'; Fi'];
        all_samples = [ all_samples sD.samples{c}(f(l),:) ];
    end

    if f(l) == 1
        all_samples = all_samples .* all_samples;
    elseif f(l) == 14
        all_samples = all_samples .* all_samples;
        
    end

    [Fi, xi] = ecdf(all_samples);
    ECDF{1} = [xi'; Fi'];
        
    h = subplot(1,2,l);
    hold on;
    for c = 1:length(sD.classes)
        tmp = ECDF{c+1};
        stairs(tmp(1,:), tmp(2,:), 'Color', colors{c+1}, 'Linewidth', 1.5);
    end
   % tmp = ECDF{1};
   % stairs(tmp(1,:), tmp(2,:), 'Color', colors{1}, 'Linewidth', 1.5);
    
    %% make plot nice and save
    % feature_name = func2str(feature_set{f});
    % title(['Feature ', int2str(f), ': ', feature_name, ' - ', property_name], 'FontSize', 9, 'Interpreter','none');
    if l == 1
        xlabel(h, 'c\_total(X)');
    else
        xlabel(h, 'r\_noon/day(X)');
    end
    ylabel(h, 'Cumulative probability');
    xlim_curr = xlim();
    if l == 1
        xlim(h, [0, 2]);
    elseif l == 2
%         xlim(h, [0, 10]);
        xlim(h, [0, 2]);
    end
    l_legend = {};
    for c = 1:length(sD.classes)
        l_legend{c} = sD.classes{c};
    end
%    l_legend{c+1} = 'All';
    legend(l_legend, 'Location', 'SE');

end

fig = make_report_ready(fig, 'size', 'features', 'fontsize', fontsize);
filename = [ figure_path, 'feature_distribution_per_class' ];
saveas(fig, [filename, '.png'], 'png');
% saveas(fig, [filename, '.eps'], 'psc2');
print('-depsc2', '-cmyk', '-r600', [filename, '.eps']);

close(fig);
    