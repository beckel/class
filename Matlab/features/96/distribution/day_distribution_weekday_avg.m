% Copyright: ETH Zurich, 12/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption every 15 minutes, distribution throughout the day,
% avg over weekdays of a week
function feature = day_distribution_weekday_avg(consumption)
    dimension = 96;
    if (strcmp(consumption, 'dim'))
		feature = dimension;
    elseif (strcmp(consumption, 'input_dim'))
        feature = 7*96;
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
   