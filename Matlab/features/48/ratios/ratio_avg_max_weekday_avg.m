% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption / maximum consumption - weekday average
function feature = ratio_avg_max_weekday_avg(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = ratio_avg_max(consumption);
        feature = mean(tmp(1:5));
    end
end
   