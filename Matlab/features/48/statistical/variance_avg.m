% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% variance throughout the day - week average
function feature = variance_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = variance(consumption);
        feature = mean(tmp(1:5));
    end
end
   