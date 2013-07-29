% variance throughout the day - week average
function feature = variance_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.variance(consumption);
        feature = mean(tmp(1:5));
    end
end
   