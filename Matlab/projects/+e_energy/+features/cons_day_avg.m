% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% average consumption during day (06am - 10pm) - weekday average
function feature = cons_day_avg(consumption)
	if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 1;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
        tmp = e_energy.features.cons_day(consumption);
        feature = mean(tmp(1:5));
    end
end
   