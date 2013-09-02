% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% night consumption / day consumption (night: 01am-05am, day: 6am-10pm)
function feature = ratio_night_day(consumption)
    if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 7;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
		feature = zeros(7,1);
        for i=1:7
            
            startNight = (i-1) * 48 + 3;
            stopNight = (i-1) * 48 + 10;
            night = mean(consumption(startNight:stopNight));
            
            startDay = (i-1) * 48 + 13;
            stopDay = (i-1) * 48 + 44;
            day = mean(consumption(startDay:stopDay));
            
            feature(i) = (night / day);
       
        end
    end
end 