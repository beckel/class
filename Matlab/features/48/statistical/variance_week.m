% Copyright: ETH Zurich, 01/2013
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% variance throughout a week 
function feature = variance_week(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = var(consumption,1);
    end
end
   