% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% variance throughout the day
function feature = variance(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 1;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = var(consumption(indices),1);
        end
    end
end 