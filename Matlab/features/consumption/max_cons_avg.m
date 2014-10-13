% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% daily maximum - week average
function feature = max_cons_avg(consumption)
	if strcmp(consumption, 'dim') == 1
		feature = 1;
    else
        if consumption.granularity ~= 30
            error('30-minute granularity required');
        end
        
        num_weeks = length(consumption.weekly_traces);
        for i=1:num_weeks
            trace = consumption.weekly_traces{i};
            tmp = cons_max(trace);
            weekly_maximum_avg(i) = mean(tmp);
        end
        
        feature = mean(weekly_maximum_avg);
        
        if feature > 5.5
            feature = 5.5;
        end
    end
end
