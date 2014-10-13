% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% first time above 2000W on weekdays (0 if threshold is not reached)
function feature = first_time_above_2000(consumption)
    if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 7;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
		feature = zeros(7,1);
        for i=1:7
			start = (i-1) * 96;
			idx = 0;
			for (j = 1:96)
			    if (consumption(start+j) > 0.5)
					idx = j;
					break;
				end
			end
			
			feature(i) = idx;
		end
	end
end 