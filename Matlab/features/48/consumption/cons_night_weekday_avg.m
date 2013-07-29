% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption during night (01am - 5am) - weekday average
function feature = cons_night_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = cons_night(consumption);
        feature = mean(tmp(1:5));
    end
end
   