function [ holidays ] = get_holidays_from_table(consumption, hol)

    assert(strcmp(hol.date{1}, '20-Jul-09') == 1);
    
    num_weeks = length(consumption.weeks);
    num_days = num_weeks * 7;
    
    holidays = zeros(1, num_days * 48);
    
    for w = 1:num_weeks
        week = consumption.weeks{w};
        for d = 1:7
            idx = (week-1)*7 + d;
            day_idx = (w-1)*7 + d;
            res_start = (day_idx-1)*48+1;
            res_stop = (day_idx)*48;
            holidays(res_start:res_stop) = str2num(hol.holidays{idx});
        end
    end
end

 