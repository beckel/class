% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% time of daily maximum
function feature = first_time_daily_max(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
			start = (i-1) * 48;
			idx = 0;
            max = 0;
			for (j = 1:48)
				if (consumption(start+j) > max)
					max = consumption(start+j);
					idx = j;
				end
			end
			
			feature(i) = idx;
		end
	end
end