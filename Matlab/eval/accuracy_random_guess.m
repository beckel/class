% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = accuracy_random_guess(sCR)

if (iscell(sCR))
    f = 1 / size(sCR{1}.confusion,1);
else
    f = 1 / size(sCR.confusion,1);
end