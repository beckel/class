% average consumption during evenings (6pm-10pm) - weekday average
function feature = cons_evening_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.cons_evening(consumption);
        feature = mean(tmp(1:5));
    end
end
   