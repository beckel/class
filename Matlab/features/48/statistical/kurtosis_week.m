% Copyright: ETH Zurich, 01/2013
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% kurtosis (exzess) over a week 
function feature = kurtosis_week(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = kurtosis(consumption);
    end
end
   