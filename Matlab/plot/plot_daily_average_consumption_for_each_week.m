% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

path = 'plot/images/weekly_averages/';
if exist(path, 'dir') == 0
    mkdir(path);
end
    
weeks = [ 1:75 ];

connection = cer_db_get_connection();
select = 'UserProfile.ID';
from = 'PreTrial_Answers INNER JOIN UserProfile ON PreTrial_Answers.ID = UserProfile.ID';
orderby = 'ID';
% Only Residents
where = { ...
     'Type = 3', ...			
};
query = query_builder(select, from, where, orderby);
fprintf('%s\n', query);
curs = fetch(exec(connection, query));
ids = cell2mat(curs.data);
close(connection);
cer_ids;

[ids, ia, ib] = intersect(ids, setdiff(union(type1, type3), exclude));

% ids = ids(1:1000);
N = length(ids);
num_weeks = length(weeks);
weekly_traces = cell(1,num_weeks);
num_traces = zeros(1, num_weeks);
for j = 1:num_weeks
    weekly_traces{j} = zeros(1, 7*48);
end
avg_time = 0;
for i = 1:N
    tic;
    id = ids(i);
    Consumer = get_weekly_consumption(id, 'cer_ireland');

    for j = 1:length(weeks)
        week = weeks(j);
        % discard trace if it contains more than 4 zeros
        weekly_trace = Consumer.consumption(week, :);
        if sum(weekly_trace == 0) > 4
            continue;
        end
        weekly_traces{j} = weekly_traces{j} + weekly_trace;
        num_traces(j) = num_traces(j) + 1;
    end
    
    t = toc;
    avg_time = (avg_time * (i-1) + t * 1) / i;
    eta = avg_time * (N - i);
    fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/N), i, N, seconds2str(eta));
    
end

save('weekly_traces.mat', 'weekly_traces', 'weeks', 'num_traces');

%% plot daily, weekday, week-end average consumption for each week
load('weekly_traces.mat');

for i = 1:length(weekly_traces)
    
    week = weeks(i);

    %% compute daily, weekend, and weekly trace
    weekly_trace = weekly_traces{i} ./ num_traces(i);
    
    daily_trace = zeros(1, 48);
    weekday_trace = zeros(1, 48);
    weekend_trace = zeros(1, 48);
    
    for j = 1:7
        tmp = weekly_trace((j-1)*48+1 : j*48);
        daily_trace = daily_trace + tmp;
        
        if j <= 5
            weekday_trace = weekday_trace + tmp;
        else
            weekend_trace = weekend_trace + tmp;
        end
    end
    
    daily_trace = daily_trace ./ 7;
    weekday_trace = weekday_trace ./ 5;
    weekend_trace = weekend_trace ./ 2;
    
    %% plot and save
    fig = figure;
    plot(0:48, [daily_trace(48), daily_trace]);
    xlim([0,48]);
    ylim([0, 1.4]);
    set(gca, 'YTick', 0 : 0.2 : 1.4);
    timeticks = 0:5:48;
    timeticks_labels = timeticks/2;
    set(gca, 'XTick', timeticks);
    set(gca, 'XTickLabel', timeticks_labels);
    xlabel('Time of Day');
    ylabel('Power Consumption [kW]');
    title(['Week ', num2str(i), ' - ', num2str(num_traces(i)), ' traces']);
    fig = make_report_ready(fig, 'size', 'presentation_large');
    if week < 10
        filename = [ 'daily_week0', num2str(week)];
    else
        filename = [ 'daily_week', num2str(week)];
    end
    saveas(fig, [path, filename, '.png'], 'png');
    close(fig);
    
    %% plot and save
    fig = figure;
    plot(0:48, [weekday_trace(48), weekday_trace]);
    xlim([0,48]);
    ylim([0, 1.4]);
    set(gca, 'YTick', 0 : 0.2 : 1.4);
    timeticks = 0:5:48;
    timeticks_labels = timeticks/2;
    set(gca, 'XTick', timeticks);
    set(gca, 'XTickLabel', timeticks_labels);
    xlabel('Time of Day');
    ylabel('Power Consumption [kW]');
    fig = make_report_ready(fig, 'size', 'presentation_large');
    if week < 10
        filename = [ 'weekday_week0', num2str(week)];
    else
        filename = [ 'weekday_week', num2str(week)];
    end
    saveas(fig, [path, filename, '.png'], 'png');
    close(fig);
    
    %% plot and save
    fig = figure;
    plot(0:48, [weekend_trace(48), weekend_trace]);
    xlim([0,48]);
    ylim([0, 1.4]);
    set(gca, 'YTick', 0 : 0.2 : 1.4);
    timeticks = 1:6:49;
    timeticks_labels = timeticks/2;
    set(gca, 'XTick', timeticks);
    set(gca, 'XTickLabel', timeticks_labels);
    xlabel('Time of Day');
    ylabel('Power Consumption [kW]');
    fig = make_report_ready(fig, 'size', 'presentation_large');
    if week < 10
        filename = [ 'weekend_week0', num2str(week)];
    else
        filename = [ 'weekend_week', num2str(week)];
    end
    saveas(fig, [path, filename, '.png'], 'png');
    close(fig);

end

    




