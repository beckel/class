% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = accuracy_random_guess(X)
    if (iscell(X))
        f = 1 / size(X{1}.confusion,1);
    elseif (isstruct(X))
        f = 1 / size(X.confusion,1);
    else
        f = 1 / size(X, 1);
    end
end
