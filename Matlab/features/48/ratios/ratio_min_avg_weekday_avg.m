% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% minimum consumption / average consumption - weekday average
function feature = ratio_min_avg_weekday_avg(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = ratio_min_avg(consumption);
        feature = mean(tmp(1:5));
    end
end
   