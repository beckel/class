% average consumption week-day (Mo 0 am - Fr 12 pm) - weekday average
function feature = cons_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(e_energy.features.cons_weekday(consumption));
    end
end
   