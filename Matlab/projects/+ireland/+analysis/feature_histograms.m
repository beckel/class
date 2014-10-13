
%% Init

feature_set_name = 'ireland.feature_set_all';

% data_path = 'projects/+ireland/results/classification/14/ireland.feature_set_all/data/';
figure_path = 'projects/+ireland/images/features/';

weeks = [ 26:26 ];
% weeks = [ 1 ]

connection = cer_db_get_connection();
select = 'UserProfile.id';
from = 'PreTrial_Answers INNER JOIN UserProfile ON PreTrial_Answers.ID = UserProfile.ID';
orderby = 'ID';
cer_ids;
where = { ...
   'UserProfile.Type BETWEEN 1 AND 3', ...
};
query = query_builder(select, from, where, orderby);
fprintf('%s\n', query);
curs = fetch(exec(connection, query));
ids = cell2mat(curs.data(:,1));
[ids, ia, ~] = intersect(ids, setdiff(union(type1, type3), exclude));

close(connection);

%% for each feature: create distribution
feature_set = eval(feature_set_name);
num_features = compose_featureset('dim', feature_set);
N = length(ids);
samples = zeros(num_features, N);

del = [];
avg_time = 0;
for i = 1:N
    tic;
    id = ids(i);
    Consumer = get_weekly_consumption(id, 'cer_ireland');

    weekly_traces = {};
    for j = 1:length(weeks)
        week = weeks(j);
        % discard trace if it contains more than 4 zeros
        weekly_trace = Consumer.consumption(week, :);
        if sum(weekly_trace == 0) > 10
            continue;
        end
        weekly_traces{end+1} = weekly_trace;
    end

    % remove household if no trace is available
    if isempty(weekly_traces)
        del = [ del, i ];
        continue;
    end

    consumption.weekly_traces = weekly_traces; 
    consumption.granularity = 30;
    consumption.id = id;
    samples(:,i) = compose_featureset(consumption, feature_set);

    t = toc;
    avg_time = (avg_time * (i-1) + t * 1) / i;
    eta = avg_time * (N - i);
    fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/N), i, N, seconds2str(eta));
end
samples(:, del) = [];

save('features.mat', 'samples');

%% print histogram for each feature
load('features.mat');

feature_set = eval(feature_set_name);
[i,j] = find(samples == Inf);
samples(i,j) = NaN;

% Add PCA features
num_pca = pca_analysis('dim');
X = samples';
[ ~, score ] = pca(zscore(X), 'NumComponents', (num_pca+1));
samples = [ samples; score' ];
idx = 1;
    
% create vector of feature names
feature_names = {};
idx = 1;
for f = 1:length(feature_set)
    D = feature_set{f}('dim');
    if D == 1
        feature_names{idx} = func2str(feature_set{f});
        idx = idx + 1;
    else
        for d = 1:D
            feature_names{idx} = [func2str(feature_set{f}), '_', num2str(d)];
            idx = idx + 1;
        end
    end
end
for f = 1:pca_analysis('dim')
    feature_names{idx} = ['pca_', num2str(f)];
    idx = idx + 1;
end
    
% plot
for f = 1:size(samples,1)
    fig = figure();
    hist(samples(f,:), 30);
    title(['Feature ', int2str(f), ': ', feature_names{f}], 'FontSize', 14, 'Interpreter','none');
    xlabel('X');
    ylabel('Frequency');
    fig = make_report_ready(fig, 'size', 'features');
    folder = [ figure_path, 'histograms/'];
    if ~exist(folder, 'dir')
        mkdir(folder)
    end
    filename = [ folder, 'feature ', int2str(f), '.png' ];
    saveas(fig, filename, 'png');
    close(fig);
end

