% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% first time above 1000W on weekdays (0 if threshold is not reached)
function feature = first_time_above_1000(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
			start = (i-1) * 48;
			idx = 0;
			for (j = 1:48)
			    if (consumption(start+j) > 1)
					idx = j;
					break;
				end
			end
			
			feature(i) = idx;
		end
	end
end 