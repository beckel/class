% evening consumption (cons_evening) / noon consumption (cons_noon) weekday average
function feature = ratio_evening_noon_weekday_avg(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.ratio_evening_noon_weekday(consumption);
        feature = mean(tmp(1:5));
    end
end
   