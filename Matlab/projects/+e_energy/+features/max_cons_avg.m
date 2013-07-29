% daily maximum - week average
function feature = max_cons_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(e_energy.features.max_cons(consumption));
    end
end
   