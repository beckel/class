% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% time above mean on weekdays (Mo 0 am - Fr 12 pm), weekday average
function feature = time_above_mean_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(time_above_mean_weekday(consumption));
    end
end
   