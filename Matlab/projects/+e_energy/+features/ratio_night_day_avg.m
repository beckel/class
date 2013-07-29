% night consumption / day consumption (night: 01am-05am, day: 6am-10pm) - weekday average
function feature = ratio_night_day_avg(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.ratio_night_day(consumption);
        feature = mean(tmp(1:5));
    end
end
   