% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% first time above 2000W on weekdays - weekday average (excluding days where threshold is not reached)
function feature = first_time_above_2000_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
		tmp = first_time_above_2000(consumption);
		sum = 0;
        count = 0;
		for (i = 1:5)
			if (tmp(i) > 0)
				count = count + 1;
				sum = sum + tmp(i);
			end
		end
		
		if (count > 0)
			feature = sum / double(count);
		else
			feature = 0;
		end
    end
end
   