% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

clearvars;

folder = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/cer_dataset/';
if exist(folder, 'dir') == 0
    mkdir(folder);
end

filename1 = 'cons_stats_cdf';
filename2 = 'cons_stats_cumsum';
filename3 = 'cons_stats_weekday_sum';
filename4 = 'cons_stats_weekly_development';

weeks = [ 1:75 ];
cer_ids;
ids = setdiff(union(type1, type3), exclude);

% plotting
width = 7.5;
height = 5;
largewidth = 17;
largeheight = 6;
fontsize = 9;

% ids = ids(1:1000);
N = length(ids);
num_weeks = length(weeks);
avg_cons_all_users = zeros(1, N);
num_traces_all_users = zeros(1, N);

weekly_traces = zeros(N, 336);
num_weekly_traces = zeros(1, N);

avg_cons_per_week = zeros(1,num_weeks);
num_traces_per_week = zeros(1,num_weeks);

avg_time = 0;
for i = 1:N
    tic;
    id = ids(i);
    Consumer = get_weekly_consumption(id, 'cer_ireland');

    num_traces_of_user = 0;
    avg_cons = 0;
        
    for j = 1:num_weeks
        week = weeks(j);
        % discard trace if it contains more than 4 zeros
        weekly_trace = Consumer.consumption(week, :);
       if sum(weekly_trace == 0) > 10
           continue;
       end
%           if ~isempty(findstr(weekly_trace, [0 0 0 0 0 0 0 0 0 0]))
%               continue;
%           end
        if j <= 52
            avg_cons = avg_cons + mean(weekly_trace);
            num_traces_of_user = num_traces_of_user + 1;
        end
        
        weekly_traces(i,:) = weekly_traces(i,:) + weekly_trace;
        num_weekly_traces(i) = num_weekly_traces(i) + 1;
        
        avg_cons_per_week(j) = avg_cons_per_week(j) + mean(weekly_trace);
        num_traces_per_week(j) = num_traces_per_week(j) + 1;
    end
    
    avg_cons_all_users(i) = avg_cons / num_traces_of_user;
    num_traces_all_users(i) = num_traces_of_user;
    
    t = toc;
    avg_time = (avg_time * (i-1) + t * 1) / i;
    eta = avg_time * (N - i);
    fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/N), i, N, seconds2str(eta));
end

idx_to_delete = find(isnan(avg_cons_all_users));
avg_cons_all_users(idx_to_delete) = [];
num_traces_all_users(idx_to_delete) = [];
household_ids = ids;
household_ids(idx_to_delete) = [];
save('avg_cons_all_users.mat', 'avg_cons_all_users', 'num_traces_all_users', 'weekly_traces', 'num_weekly_traces', 'avg_cons_per_week', 'num_traces_per_week', 'household_ids');

%% plot daily, weekday, week-end average consumption for each week
load('avg_cons_all_users.mat');

%% cumulative probability distribution of daily consumption average (first 52 weeks)
avg_cons_all_users_yearly = avg_cons_all_users * 24 * 7 * 52;
% interval = round(0.01*avg_cons_all_users_yearly) : round(0.99*avg_cons_all_users_yearly);
fig = figure;
cdfplot(avg_cons_all_users_yearly / 1000);
xlabel('Yearly power consumption [kWh]');
ylabel('Cumulative probability');
set(gcf,'color','w');
fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
export_fig('-cmyk', '-pdf', [folder, filename1, '.pdf']);
% print('-dpdf', '-cmyk', '-r600', [folder, filename1, '.pdf']);
close(fig);

%% cumulative sum (first 52 weeks)
cons_all_users_sorted = sort(avg_cons_all_users_yearly);
percentage_of_overall = cons_all_users_sorted / sum(cons_all_users_sorted);
cumulative_sum = cumsum(sort(percentage_of_overall));
fig = figure;
plot(cumulative_sum);
xlim([0,length(cumulative_sum)]);
xlabel('Number of households');
ylabel('Share of total consumption');
% title('Cumulative sum');
set(gcf,'color','w');
grid on;
fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
% print('-dpdf', '-cmyk', '-r600', [folder, filename2, '.pdf']);
export_fig('-cmyk', '-pdf', [folder, filename2, '.pdf']);
close(fig);

%% plot average weekday trace (whole 75 weeks)
sum_of_weekly_traces = sum(weekly_traces, 1);
trace = sum_of_weekly_traces / sum(num_weekly_traces) * 1000;
fig = figure;
plot(0:7*48, [ trace(7*48), trace(1:7*48) ]);
% xlabel('Time');
ylabel('Power consumption [W]');
xlim([0,7*48]);
% ylim([0, 1.4]);
% set(gca, 'YTick', 0 : 0.2 : 1.4);
% timeticks = 0:5:48;
xticks_labels = {'Mo', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
xticks = 25:48:336;
xticks = set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', xticks_labels);
% title('Average consumption of all households over one week');
set(gcf,'color','w');
grid on;
fig = make_report_ready(fig, 'size', [largewidth, largeheight], 'fontsize', fontsize);
% print('-dpdf', '-cmyk', '-r600', [folder, filename3, '.pdf']);
export_fig('-cmyk', '-pdf', [folder, filename3, '.pdf']);
close(fig);

%% plot weekly average consumption (whole 75 weeks)
weekly_average_consumption = (avg_cons_per_week ./ num_traces_per_week) * 24 * 7;
fig = figure;
plot(weekly_average_consumption);
xlabel('Week');
ylabel('Power consumption [kWh]');
xlim([1, 75]);
% title('Average weekly consumption of all households over the trial');
set(gcf,'color','w');
grid on;
fig = make_report_ready(fig, 'size', [largewidth, largeheight], 'fontsize', fontsize);
% print('-dpdf', '-cmyk', '-r600', [folder, filename4, '.pdf']);
export_fig('-cmyk', '-pdf', [folder, filename4, '.pdf']);
close(fig);
