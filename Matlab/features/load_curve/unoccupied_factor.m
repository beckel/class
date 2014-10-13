% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% average consumption during day (06am - 10pm) - total average
function feature = unoccupied_factor(consumption)
    if strcmp(consumption, 'dim') == 1
		feature = 1;
    else
    
        if consumption.granularity ~= 30
            error('30-minute granularity required');
        end
        
        feature = NaN;
    end
end
   