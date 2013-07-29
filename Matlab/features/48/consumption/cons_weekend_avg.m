% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption week-end (Sa 0 am - Su 12 pm) - week-end average
function feature = cons_weekend_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = mean(cons_weekend(consumption));
    end
end
   