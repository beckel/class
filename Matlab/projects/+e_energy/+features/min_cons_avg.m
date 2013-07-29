% daily minimum - week average
function feature = min_cons_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(e_energy.features.min_cons(consumption));
    end
end
   