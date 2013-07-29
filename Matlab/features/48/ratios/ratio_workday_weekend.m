% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% workday consumption / week-end consumption
function feature = ratio_workday_weekend(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        feature = cons_weekday_avg(consumption) / cons_weekend_avg(consumption);    
    end
end
   