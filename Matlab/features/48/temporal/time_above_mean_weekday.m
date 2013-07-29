% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% time above mean on weekdays (Mo 0 am - Fr 12 pm)
function feature = time_above_mean_weekday(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 5;
	else
		feature = zeros(5,1);
        for i=1:5
            start = (i-1) * 48 + 1;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = sum(consumption(indices) > mean(consumption(indices)));
        end
    end
end 
   