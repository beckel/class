% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% night consumption / day consumption (night: 01am-05am, day: 6am-10pm) - weekday average
function feature = ratio_night_day_avg(consumption)
    if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 1;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
        tmp = ratio_night_day(consumption);
        feature = mean(tmp(1:5));
    end
end
   