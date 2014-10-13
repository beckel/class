% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function Y = two_submatrix(X, base)
	first = ind2logic(base, size(X, 1));
    other = ~first;
    
    Y = [ X(first, first), sum(sum(X(first, other))); sum(sum(X(other, first))), sum(sum(X(other, other))) ];
end
