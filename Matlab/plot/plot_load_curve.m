
path = 'plot/load_curve/';

day = 2;
week = 29;
household = 2069;

consumption = get_weekly_consumption(household, 'cer_ireland');
start = (day-1) * 48 + 1;
stop = day * 48;

% values
consumption = consumption.consumption(week, start:stop);
timeline = 0:48;

% plot
fig = figure;
% plot([timeline], [consumption(length(consumption)), consumption], '-x');
plot([timeline], [consumption(length(consumption)), consumption]);

% x axis
xlim([0,48]);
timeticks = timeline(1:6:49)
timeticks_labels = timeticks/2
set(gca, 'XTick', timeticks);
set(gca, 'XTickLabel', timeticks_labels);
xlabel('Time of Day');

% y axis
ylabel('Power Consumption [kW]');

fig = make_report_ready(fig, 'size', 'presentation_large');

% save image
if exist(path, 'dir') == 0
    mkdir(path);
end
filename = [path, 'daily_consumption', '.eps'];
saveas(fig, filename, 'psc2');
pause(2);
close(fig);