% Copyright: ETH Zurich, 01/2013
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% skewness over the course of a week-day
function feature = skewness_week(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
       feature = skewness(consumption, 0);
    end
end
