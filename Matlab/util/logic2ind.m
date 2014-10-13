% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function ind = logic2ind(logic)
	N = size(logic,1);
	ind = zeros(N,max(sum(logic,2)));
	for i = 1:N
		idx = find(logic(i,:) == true);
		ind(i,1:length(idx)) = idx;
	end
end