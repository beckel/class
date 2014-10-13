% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = area_under_curve(sCR)
	if (iscell(sCR))
		N = length(sCR);
		f = zeros(1,N);
		for i = 1:N
			f(i) = area_under_curve(sCR{i});
		end
		f = mean(f);
	elseif (isstruct(sCR))
        distances = sortrows(sCR.distance, 1);
        num_class1 = sum(distances(:,1) == 1);
        distances(1:num_class1,:) = sortrows(distances(1:num_class1,:), -2);
        distances(num_class1+1:end,2) = -1 * distances(num_class1+1:end,2);
        distances(num_class1+1:end,:) = sortrows(distances(num_class1+1:end,:), -2);
        samples = distances(:,2);
        truth = distances(:,3);

        [X,Y,T,AUC] = perfcurve(truth, samples, 1);

        f = AUC;
    else
		f = 0;
	end
end