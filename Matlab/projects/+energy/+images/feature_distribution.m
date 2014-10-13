feature_set_name = 'energy.feature_set_all';

% data_path = 'projects/+ireland/results/classification/14/ireland.feature_set_all/data/';
figure_path = 'projects/+energy/+images/feature_distribution/';

fontsize = 8;

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

%% plot

% consumption day average
fig = figure;
h = subplot(1,2,1);
qqplot(samples(1,:));
title('');
xlabel(h, 'Standard normal quantities');
ylabel(h, 'Quantities of c\_total');

h = subplot(1,2,2);
qqplot(samples(15,:));
title('');
xlabel(h, 'Standard normal quantities');
ylabel(h, 'Quantities of r\_morning/noon');

fig = make_report_ready(fig, 'size', [14, 4.5], 'fontsize', fontsize);

filename = 'feature_distributions';
warning off
mkdir(figure_path);
warning on
% saveas(fig, [figure_path, filename, '.eps'], 'psc2');
print('-depsc2', '-cmyk', '-r600', [figure_path, filename, '.eps']);
saveas(fig, [figure_path, filename, '.png'], 'png');
close(fig);
