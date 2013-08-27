% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% average consumption week-end (Sa 0 am - Su 12 pm)
function feature = cons_evening(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 2;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 48*7;
    else
		feature = zeros(2,1);
        for i=1:2
            start = (5+i-1) * 48 + 1;
            stop = (5+i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
        end
    end
end 
   