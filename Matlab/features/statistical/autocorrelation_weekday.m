% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function feature = autocorrelation_weekday(consumption)
    
    if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 1;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
        start = 1;
        stop = 5 * 48;
        tmp = autocorr(consumption(start:stop), 48);
        feature = tmp(48);
    end
end 
   