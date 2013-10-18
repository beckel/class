% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% average consumption week-end (Sa 0 am - Su 12 pm)
function feature = cons_weekend(consumption)
    N = length(consumption);
    D = N/7;
    
    start = 5*D + 1;
    stop = 7*D;
    feature = mean(consumption(start:stop));
end 
   