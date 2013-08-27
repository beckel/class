% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = accuracy(sCR)
	if (iscell(sCR))
		N = length(sCR);
		f = zeros(1,N);
		for i = 1:N
			f(i) = accuracy(sCR{i});
		end
		f = mean(f);
	elseif (isstruct(sCR))
		% Rate of correct decisions
		N = sum(sum(sCR.confusion));
		f = sum(diag(sCR.confusion)) / N; 
    else
		f = 0;
	end
end