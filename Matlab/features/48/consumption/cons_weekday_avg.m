% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption week-day (Mo 0 am - Fr 12 pm) - weekday average
function feature = cons_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(cons_weekday(consumption));
    end
end
   