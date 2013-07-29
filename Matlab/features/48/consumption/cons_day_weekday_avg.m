% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption during day (06am - 10pm) - weekday average
function feature = cons_day_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = cons_day(consumption);
        feature = mean(tmp(1:5));
    end
end
   