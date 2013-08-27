% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% average consumption every 15 minutes, distribution throughout the day,
% avg over weekdays of a week
function feature = day_distribution(consumption)
    dimension = 96;
    if (strcmp(consumption, 'dim'))
		feature = dimension;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
        if length(consumption) ~= 96
            error('Wrong dimension: %d - 96 expected\n', length(consumption));
        end
        feature(1:96) = zeros(1,96);
        if sum(consumption) ~= 0
            feature(1:96) = consumption / sum(consumption);
        end
    end
end 
   