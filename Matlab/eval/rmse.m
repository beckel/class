% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = rmse(sR)
	if (iscell(sR))
		num_folds = length(sR);
        prediction = [];
        truth = [];
        for f = 1:num_folds
			prediction = [ prediction, sR{f}.prediction];
            truth = [ truth, sR{f}.truth];
        end
        x.prediction = prediction;
        x.truth = truth;
		f = rmse(x);
	elseif (isstruct(sR))
		f = sqrt(mean((sR.truth - sR.prediction).^2));
    else
		error('Should not happen - cell or struct with prediction and truth required');
	end
end
