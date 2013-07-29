% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% number of peaks: number (on a day) of values with two neighbors that have at least 200mW less consumption - week average
function feature = num_peaks_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        tmp = num_peaks(consumption);
        feature = mean(tmp(1:5));
    end
end
   