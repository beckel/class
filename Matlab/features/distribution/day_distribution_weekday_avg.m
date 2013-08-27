% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% average consumption every 15 minutes, distribution throughout the day,
% avg over weekdays of a week
function feature = day_distribution_weekday_avg(consumption)
    dimension = 96;
    if (strcmp(consumption, 'dim'))
		feature = dimension;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
        feature(1:96) = zeros(1,96);
        dailyConsumption = zeros(1,96);
        for i=0:4
            indeces = (96*i)+1 : 96*(i+1);
            dailyConsumption = dailyConsumption + consumption(indeces);
        end
        
        if sum(dailyConsumption) ~= 0
            feature(1:96) = dailyConsumption(1:96) / sum(dailyConsumption);
        end
    end
end 
   