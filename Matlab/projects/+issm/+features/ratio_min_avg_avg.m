% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% minimum consumption / average consumption - weekday average
function feature = ratio_min_avg_avg(consumption)
    if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 1;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
        tmp = issm.features.ratio_min_avg(consumption);
        feature = mean(tmp(1:5));
    end
end
   