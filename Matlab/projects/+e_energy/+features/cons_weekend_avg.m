% average consumption week-end (Sa 0 am - Su 12 pm) - week-end average
function feature = cons_weekend_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(e_energy.features.cons_weekend(consumption));
    end
end
   