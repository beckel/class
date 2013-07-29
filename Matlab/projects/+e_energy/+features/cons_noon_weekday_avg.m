% average consumption around noon (10am - 2pm) - weekday average
function feature = cons_noon_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.cons_noon(consumption);
        feature = mean(tmp(1:5));
    end
end
   