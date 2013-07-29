% Copyright: ETH Zurich, 01/2013
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

function feature = autocorrelation_weekday(consumption)
    
    if (strcmp(consumption, 'dim'))
		feature = 1;
    else
        start = 1;
        stop = 5 * 48;
        tmp = autocorr(consumption(start:stop), 48);
        feature = tmp(48);
    end
end 
   