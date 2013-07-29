% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption around noon (10am - 2pm) - weekday average
function feature = cons_noon_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = cons_noon(consumption);
        feature = mean(tmp(1:5));
    end
end
   