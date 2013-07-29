% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption week-end (Sa 0 am - Su 12 pm)
function feature = cons_evening(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 2;
	else
		feature = zeros(2,1);
        for i=1:2
            start = (5+i-1) * 48 + 1;
            stop = (5+i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
        end
    end
end 
   