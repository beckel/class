
warning('OFF', 'stats:regress:RankDefDesignMat');

% config
all_weeks = 1:75;
num_measurements = 7 * 75;

cer_ids;
ids = setdiff(union(type1, type3), exclude);

% output
temperature_and_daylight_variables = zeros(length(ids), 2);

% input: temperature
[temperature.time, temperature.value] = import_temperature('temperature.csv');
assert(strcmp(temperature.time{1}, '2009-07-20-00:00') == 1);
temperature.value = mean(reshape(temperature.value, 48, length(temperature.value)/48), 1)';
assert(length(temperature.value) == num_measurements);

% weekday/week-end
weekday_weekend = zeros(2, num_measurements);
for dow = 1:7
    if dow == 6 || dow == 7
        weekday_weekend(2, dow:7:end) = 1;
    else
        weekday_weekend(1, dow:7:end) = 1;
    end
end
    
for i = 1:length(ids)
    fprintf('Processing household %d of %d\n', i, length(ids));
    
    id = ids(i);

    Consumer = get_weekly_consumption(id, 'cer_ireland');

    all_weekly_traces = {};
    selected_weeks = {};
    weeks_to_exclude = {};

    for j = 1:length(all_weeks)
        weekly_trace = Consumer.consumption(j,:);
        weekly_trace = mean(reshape(weekly_trace, 48, length(weekly_trace)/48), 1);
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
        start = (week-1) * 7 + 1;
        stop = week * 7;
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
    X = [ X, temperature.value ];
    % X = [ X, holidays' ];
    X = [ X, weekday_weekend' ];
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
    
end

save('data_selection/temperature_and_daylight_variables_daily.mat', 'temperature_and_daylight_variables');
    