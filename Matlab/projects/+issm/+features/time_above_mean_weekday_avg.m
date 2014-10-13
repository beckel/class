% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% time above mean on weekdays (Mo 0 am - Fr 12 pm), weekday average
function feature = time_above_mean_weekday_avg(consumption)
	if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 1;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
        feature = mean(issm.features.time_above_mean_weekday(consumption));
    end
end
   