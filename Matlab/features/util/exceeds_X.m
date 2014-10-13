% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% first time above certain threshold X (0 if threshold is not reached)
function feature = exceeds_X(consumption, X)

    N = length(consumption);
    D = N/7;
    
    feature = zeros(7,1);
    for i=1:7
        start = (i-1)*D + 1;
        stop = i*D;
        if sum(consumption(start:stop) > X) > 0
            feature(i) = 1;
            continue;
        end
    end
end 
