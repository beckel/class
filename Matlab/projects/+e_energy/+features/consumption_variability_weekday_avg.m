% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% consumption_variability - Sum(|P(t)-P(t-1)|) for all t throughout a day - week average
function feature = consumption_variability_weekday_avg(consumption)
	if (strcmp(consumption, 'dim'))
		feature = 1;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
        tmp = e_energy.features.consumption_variability(consumption);
        feature = mean(tmp(1:5));
    end
end
   