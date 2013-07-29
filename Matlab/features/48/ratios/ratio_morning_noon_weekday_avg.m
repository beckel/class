% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% morning consumption (cons_morning) / noon consumption (cons_noon) weekday average
function feature = ratio_morning_noon_weekday_avg(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = ratio_morning_noon(consumption);
        feature = mean(tmp(1:5));
    end
end
   