% minimum consumption / average consumption - weekday average
function feature = ratio_min_avg_avg(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = e_energy.features.ratio_min_avg(consumption);
        feature = mean(tmp(1:5));
    end
end
   