% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% number of peaks: number (on a day) of values with two neighbors that have at least 200mW less consumption
function feature = num_peaks(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            count = 0;
            start = (i-1) * 48 + 1;
            for (j=1:46)
                b1 = consumption(start+j) - consumption(start+j-1);
                b2 = consumption(start+j) - consumption(start+j+1);
                if (b1 > 0.2 & b2 > 0.2)
                    count = count + 1;
                end
            end
            
            feature(i) = count;
            
        end
    end
end
