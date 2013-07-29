% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% time above mean on week-end (Sa 0 am - Su 12 pm) - week-end average
function feature = time_above_mean_weekend_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(time_above_mean_weekend(consumption));
    end
end
   