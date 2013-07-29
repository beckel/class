% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% daily maximum - week average
function feature = max_cons_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(max_cons(consumption));
    end
end
   