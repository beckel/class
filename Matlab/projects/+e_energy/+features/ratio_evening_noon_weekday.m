% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% noon consumption (cons_noon) / evening consumption (cons_evening) on weekdays
function feature = ratio_evening_noon_weekday(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 5;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
		feature = zeros(5,1);
        for i=1:5
            
            startNoon = (i-1) * 48 + 21;
            stopNoon = (i-1) * 48 + 28;
            noon = mean(consumption(startNoon:stopNoon));
            
            startEvening = (i-1) * 48 + 37;
            stopEvening = (i-1) * 48 + 44;
            evening = mean(consumption(startEvening:stopEvening));

            feature(i) = log(evening / noon);
            
            if feature(i) < -5
                feature(i) = -5;
            end
            
            if feature(i) > 5
                feature(i) = 5;
            end
        end
    end
end 

