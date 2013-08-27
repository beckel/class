% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = accuracy_biased_random_guess(sCR)
	if (iscell(sCR))
		N = length(sCR);
		f = zeros(1,N);
		for i = 1:N
            confusion = sCR{i}.confusion;
            for j=1:size(confusion,1)
                tmp = sum(confusion(j,:)) / sum(sum(confusion));
                f(i) = f(i) + tmp^2;
            end
		end
		f = mean(f);
	elseif (isstruct(sCR))
        f = 0;
        for i=1:size(sCR.confusion,1)
            tmp = sum(sCR.confusion(i,:)) / sum(sum(sCR.confusion));
            f = f + tmp^2;
        end
	else
		f = 0;
	end
end