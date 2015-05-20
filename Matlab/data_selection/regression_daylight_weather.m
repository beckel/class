
warning('OFF', 'stats:regress:RankDefDesignMat');

% config
all_weeks = 1:75;
num_measurements = 48 * 7 * 75;

% output
temperature_and_daylight_variables = zeros(length(ids), 4);

% input: sunlight & temperature
[sun.date, sun.rise, sun.set] = import_sun('sun.csv', 2, 1078);
[temperature.time, temperature.value] = import_temperature('temperature.csv');
assert(strcmp(temperature.time{1}, '2009-07-20-00:00') == 1);
assert(length(temperature.value) == num_measurements);

% daylight = get_daylight_from_sunrise_sunset(consumption, sun);
% darkness = ones(1, length(daylight)) - daylight;
sunrise_hours = get_sunrise_hour_from_sunrise_sunset(all_weeks, sun);
sunset_hours = get_sunset_hour_from_sunrise_sunset(all_weeks, sun);

% weekday/week-end
weekday_weekend = zeros(2, num_measurements);
for dow = 1:7
    for tod = 1:48
        idx = (dow-1)*48 + tod;
        if dow == 6 || dow == 7
            weekday_weekend(2, idx:48*7:end) = 1;
        else
            weekday_weekend(1, idx:48*7:end) = 1;
        end
    end
end
    
% time of day
time_of_day = zeros(24, num_measurements);
for tod = 1:24
    x = zeros(1, num_measurements);
    idx1 = (tod-1)*2 + 1;
    idx2 = tod*2;
    time_of_day(tod, idx1:48:end) = 1;
    time_of_day(tod, idx2:48:end) = 1;
end

% month
month = zeros(12, num_measurements);
for m = 1:12
    for tod = 1:48
        idx = (m-1)*48 + tod;
        month(m, idx:48*7:end) = 1;
    end
end
    
cer_ids;
ids = setdiff(union(type1, type3), exclude);
for i = 1:length(ids)
    fprintf('Processing household %d of %d\n', i, length(ids));
    
    id = ids(i);

    Consumer = get_weekly_consumption(id, 'cer_ireland');

    all_weekly_traces = {};
    selected_weeks = {};
    weeks_to_exclude = {};

    for j = 1:length(all_weeks)
        weekly_trace = Consumer.consumption(j,:);
        all_weekly_traces{end+1} = weekly_trace;
        if sum(weekly_trace == 0) > 10
            weeks_to_exclude{end+1} = j;
        else
            selected_weeks{end+1} = j;
        end
    end

    % only use "valid" weeks in the analysis
    values_to_use_in_analysis = zeros(1, num_measurements);
    for w = 1:length(selected_weeks)
        week = selected_weeks{w};
        start = (week-1) * 336 + 1;
        stop = week * 336;
        values_to_use_in_analysis(start:stop) = 1;
    end

    % holidays
    % [hol.date, hol.holidays] = import_holidays('holidays.csv', 2, 896);
    % holidays = get_holidays_from_table(consumption, hol);

    % consumption
    cons = cell2mat(all_weekly_traces);

    %% Regression: Daylight
    
    %% with constant term 
    X = [];
    X = [ X, sunrise_hours', sunset_hours' ];
    X = [ X, temperature.value ];
    % X = [ X, holidays' ];
    X = [ X, weekday_weekend' ];
    X = [ X, time_of_day' ];
    X = [ X, values_to_use_in_analysis' ];
    X = [ X, ones(length(cons), 1) ];

    y = cons';

    % b: coefficient estimates
    % bint: 95% estimates of the coefficient estimates
    % r: residuals
    % rint: outlier detection
    % http://www.mathworks.ch/ch/help/stats/regress.html
    % [b1,bint1,r1,rint1,stats1] = regress(training_truth, sC.training_set');
    [b,bint,r,rint,stats] = regress(y, X);
    
    % add daylight and darkness
    temperature_and_daylight_variables(i, 1) = id;
    temperature_and_daylight_variables(i, 2) = b(1);
    temperature_and_daylight_variables(i, 3) = b(2);
    temperature_and_daylight_variables(i, 4) = b(3);
    
end

save('data_selection/temperature_and_daylight_variables.mat', 'temperature_and_daylight_variables');
    