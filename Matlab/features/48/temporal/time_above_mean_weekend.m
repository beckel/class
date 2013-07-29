% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% time above mean on week-end (Sa 0 am - Su 12 pm)
function feature = time_above_mean_weekend(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 2;
	else
		feature = zeros(2,1);
        for i=1:2
            start = (5+i-1) * 48 + 1;
            stop = (5+i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = sum(consumption(indices) > mean(consumption(indices)));
        end
    end
end 
   