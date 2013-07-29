% average consumption during mornings (06-10am) - weekday average
function feature = cons_morning_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.cons_morning(consumption);
        feature = mean(tmp(1:5));
    end
end
   