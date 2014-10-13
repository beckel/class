function [ sunset_hour ] = get_sunset_hour_from_sunrise_sunset(consumption, sun)

    assert(strcmp(sun.date{1}, '20-Jul-09') == 1);
    
    num_weeks = length(consumption.weeks);
    num_days = num_weeks * 7;
    
    sunset_hour = zeros(1, num_days * 48);
    
    for w = 1:num_weeks
        week = consumption.weeks{w};
        for d = 1:7
            idx = (week-1)*7 + d;
            sunrise = sun.rise{idx};
            hours = round((datenum(sunrise, 'HH:MM') - datenum('00:00', 'HH:MM')) * 24);
            minutes = round(60 * mod((datenum(sunrise, 'HH:MM') - datenum('00:00', 'HH:MM'))*24, 1));
            half = 0;
            if minutes >= 30
                half = 1;
            end
            daylight_start = 2 * hours + half + 1 + 1;
            
            sunset = sun.set{idx};
            hours = round((datenum(sunset, 'HH:MM') - datenum('00:00', 'HH:MM')) * 24);
            minutes = round(60 * mod((datenum(sunset, 'HH:MM') - datenum('00:00', 'HH:MM'))*24, 1));
            half = 0;
            if minutes >= 30
                half = 1;
            end
            daylight_stop = 2 * hours + half;
            
            daylight_idx = (w-1)*7 + d;

            res_start = (daylight_idx-1)*48+daylight_stop;
            res_stop = (daylight_idx-1)*48+daylight_stop + 1;
            sunset_hour(res_start : res_stop) = 1;
        end
    end
end

