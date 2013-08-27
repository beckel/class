% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% first time above 1000W on weekdays - weekday average (excluding days where threshold is not reached)
function feature = first_time_above_1000_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
		tmp = issm.features.first_time_above_1000(consumption);
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
   