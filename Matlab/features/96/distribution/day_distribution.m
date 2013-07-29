% Copyright: ETH Zurich, 12/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% average consumption every 15 minutes, distribution throughout the day,
% avg over weekdays of a week
function feature = day_distribution(consumption)
    dimension = 96;
    if (strcmp(consumption, 'dim'))
		feature = dimension;
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
   