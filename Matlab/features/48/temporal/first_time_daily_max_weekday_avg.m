% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% time of daily maximum - week average
function feature = first_time_daily_max_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
		tmp = first_time_daily_max(consumption);
		feature = mean(tmp(1:5));
	end
end
   