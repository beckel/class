% number of peaks: number (on a day) of values with two neighbors that have at least 200mW less consumption - week average
function feature = num_peaks_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.num_peaks(consumption);
        feature = mean(tmp(1:5));
    end
end
   