% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% average consumption during night (01am - 5am)
function feature = cons_night(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 3;
            stop = (i-1) * 48 + 10;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
            
            if (feature(i) > 1)
                feature(i) = 1;
            end
            
            feature(i) = sqrt(feature(i));
            
        end
    end
end 
   