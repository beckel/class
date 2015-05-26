% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

clearvars;

folder = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/weather/';
if exist(folder, 'dir') == 0
    mkdir(folder);
end

cer_ids;
ids = setdiff(union(type1, type3), exclude);

% plotting
width = 17.5;
height = 6.5;
fontsize = 9;

N = length(ids);
num_days = 7*75;

%% consumption
sum_daily_cons = zeros(1, num_days);
num_daily_cons = zeros(1, num_days);
for i = 1:N
    fprintf('Household no. %d of %d\n', i, N);
    id = ids(i);
    Consumer = get_weekly_consumption(id, 'cer_ireland');
    for week = 1:75
        weekly_trace = Consumer.consumption(week, :);
        if sum(weekly_trace == 0) > 10
           continue;
        end
        for day = 1:7
            idx_start = (day-1)*48 + 1;
            idx_stop = day*48;
            cons = weekly_trace(idx_start:idx_stop);
            num_of_day = (week-1)*7 + day;
            sum_daily_cons(num_of_day) = sum_daily_cons(num_of_day) + mean(cons) * 24;
            num_daily_cons(num_of_day) = num_daily_cons(num_of_day) + 1;
        end
    end
end

avg_daily_cons = sum_daily_cons ./ num_daily_cons;

%% temperature
[temperature.time, temperature.values] = import_temperature('temperature.csv');
assert(strcmp(temperature.time{1}, '2009-07-20-00:00') == 1);
assert(length(temperature.values) == 7*75*48);
avg_daily_temperature = zeros(1, num_days);
for day = 1:7*75
    idx_start = (day-1)*48 + 1;
    idx_stop = day*48;
    avg_daily_temperature(day) = mean(temperature.values(idx_start:idx_stop));
end

%% regression line

X = [ ones(length(avg_daily_temperature), 1), avg_daily_temperature' ];
y = avg_daily_cons';
[b,bint,r,rint,stats] = regress(y, X);

%% plot
fig = figure;
plot(avg_daily_temperature, avg_daily_cons, '.');
hold on;
min_x = min(avg_daily_temperature);
max_x = max(avg_daily_temperature);
plot([min_x, max_x], [b(2)*min_x + b(1), b(2)*max_x + b(1)]);
xlabel('Temperature [^{\circ}C]');
ylabel('Electricity consumption [kWh]');
xlim([min_x - 0.5, max_x + 0.5]);
set(gcf,'color','w');
% legend({'Specified in m^2', 'Specified in ft^2'});
grid on;
fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
filename = 'temp_vs_consumption';
% print('-dpdf', '-cmyk', '-r600', [folder, filename, '.pdf']);
export_fig('-cmyk', '-pdf', [folder, filename, '.pdf']);
close(fig);

