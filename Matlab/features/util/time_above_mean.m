% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% time above mean on weekdays (Mo 0 am - Fr 12 pm)
function feature = time_above_mean(consumption)
    
    N = length(consumption);
    D = N/7;

    feature = zeros(7,1);
    for i=1:7
        start = (i-1) * D + 1;
        stop = i*D;
        indices = start : stop;
        feature(i) = sum(consumption(indices) > mean(consumption(indices))) / D;
    end
end
