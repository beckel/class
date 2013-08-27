% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function confusion = calc_confusion(truth, prediction, C)
	confusion = zeros(C,C);
	for tr = 1:C
		for pr = 1:C
			confusion(tr,pr) = sum(and(truth == tr, prediction == pr));
		end
	end
end