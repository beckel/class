% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% consumption_variability - Sum(|P(t)-P(t-1)|) for all t throughout a day
function feature = consumption_variability(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
		feature = zeros(7,1);
        for i=1:7
            
            start = (i-1) * 48 + 2;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            
            feature(i) = sum(abs(consumption(indices) - consumption(indices-1)));
        end
    end
end 
   