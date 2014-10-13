% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

clearvars;

colors = {
    'r'; ...
    'b'; ...
    'k'; ...
    'g'; ...
    };
            
% class_func = @class_singles;
class_func = @class_eheating;
sClass = class_func();
classes = sClass.classes;
constraints = sClass.constr;
name = class_func('name');

C = length(classes);

path = ['plot/images/weekly_averages/classes/', name, '/'];
if exist(path, 'dir') == 0
    mkdir(path);
end

weeks = [ 1:75 ];

% get household ids
connection = cer_db_get_connection();
select = 'UserProfile.id';
from = 'PreTrial_Answers INNER JOIN UserProfile ON PreTrial_Answers.ID = UserProfile.ID';
orderby = 'ID';
ids = cell(1,C);
cer_ids;

for c = 1:C
    % Only Residents 
    where = { ...
%         'UserProfile.Type = 1', ...
        constraints{c}, ...
    };
    query = query_builder(select, from, where, orderby);
    fprintf('%s\n', query);
    curs = fetch(exec(connection, query));
    ids{c} = cell2mat(curs.data(:,1));
   
    [ids{c}, ia, ib] = intersect(ids{c}, setdiff(union(type1, type3), exclude));
    if size(curs.data, 2) == 2
        tmp = cell2mat(curs.data(:,2))';
        values{c} = tmp(ia);
    end
end
close(connection);
    
% remove "exclude" ids
for c = 1:C
    del{c} = [];
    for i = 1:length(ids{c})
        if any(exclude == ids{c}(i))
            del{c} = [ del{c}, i ];
        end
    end
    ids{c}(del{c}) = [];
end

% ids = ids(1:1000);
num_weeks = length(weeks);
weekly_traces = cell(C,num_weeks);
num_traces = zeros(C, num_weeks);
for c = 1:C
    for j = 1:num_weeks
        weekly_traces{c,j} = zeros(1, 7*48);
    end
    avg_time = 0;
    N = length(ids{c});
    for i = 1:N
        tic;
        id = ids{c}(i);
        Consumer = get_weekly_consumption(id, 'cer_ireland');

        for j = 1:length(weeks)
            week = weeks(j);
            % discard trace if it contains more than 4 zeros
            weekly_trace = Consumer.consumption(week, :);
            if sum(weekly_trace == 0) > 10
                continue;
            end
            weekly_traces{c,j} = weekly_traces{c,j} + weekly_trace;
            num_traces(c,j) = num_traces(c,j) + 1;
        end

        t = toc;
        avg_time = (avg_time * (i-1) + t * 1) / i;
        eta = avg_time * (N - i);
        fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/N), i, N, seconds2str(eta));
    end
end

% plot daily, weekday, week-end average consumption for each week
for i = 1:size(weekly_traces, 2)
    
    %% compute daily, weekend, and weekly trace for each class
    for c = 1:C
        weekly_trace = weekly_traces{c, i} ./ num_traces(c, i);
    
        daily_trace{c} = zeros(1, 48);
        weekday_trace{c} = zeros(1, 48);
        weekend_trace{c} = zeros(1, 48);
    
        for j = 1:7
            tmp = weekly_trace((j-1)*48+1 : j*48);
            daily_trace{c} = daily_trace{c} + tmp;

            if j <= 5
                weekday_trace{c} = weekday_trace{c} + tmp;
            else
                weekend_trace{c} = weekend_trace{c} + tmp;
            end
        end
    
        daily_trace{c} = daily_trace{c} ./ 7;
        weekday_trace{c} = weekday_trace{c} ./ 5;
        weekend_trace{c} = weekend_trace{c} ./ 2;
    end
    
    %% plot and save
    
    week = weeks(i);
    
    fig = figure;
    hold on;
    for c = 1:C
        plot(0:48, [daily_trace{c}(48), daily_trace{c}], 'Color', colors{c});
    end
    legend(classes, 'Location', 'NW');
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
        filename = [ 'daily_week0', num2str(week)];
    else
        filename = [ 'daily_week', num2str(week)];
    end
    saveas(fig, [path, filename, '.png'], 'png');
    close(fig);
    
    %% plot and save
    fig = figure;
    hold on;
    for c = 1:C
        plot(0:48, [weekday_trace{c}(48), weekday_trace{c}], 'Color', colors{c});
    end
    legend(classes, 'Location', 'NW');
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
    hold on;
    for c = 1:C
        plot(0:48, [weekend_trace{c}(48), weekend_trace{c}], 'Color', colors{c});
    end
    legend(classes, 'Location', 'NW');
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

    




