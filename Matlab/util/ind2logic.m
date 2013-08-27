% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function logic = ind2logic(ind, C)
	N = size(ind,1);
	logic = false([N,C]);
	for i = 1:N
		l = false([1, C]);
		l(ind(i,:)) = true;
		logic(i,:) = l;
	end
end