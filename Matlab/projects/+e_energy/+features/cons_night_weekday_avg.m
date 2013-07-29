% average consumption during night (01am - 5am) - weekday average
function feature = cons_night_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.cons_night(consumption);
        feature = mean(tmp(1:5));
    end
end
   