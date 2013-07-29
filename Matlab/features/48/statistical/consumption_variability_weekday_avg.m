% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% consumption_variability - Sum(|P(t)-P(t-1)|) for all t throughout a day - week average
function feature = consumption_variability_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = consumption_variability(consumption);
        feature = mean(tmp(1:5));
    end
end
   