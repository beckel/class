% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption week-day (Mo 0 am - Fr 12 pm)
function feature = cons_weekday(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 5;
	else
		feature = zeros(5,1);
        for i=1:5
            start = (i-1) * 48 + 1;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
        end
    end
end 
   