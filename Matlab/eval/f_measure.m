% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = f_measure(sCR, idx, basis)
    if nargin < 3
        basis = 1;
    end
    
	if (iscell(sCR))
		N = length(sCR);
		f = zeros(1,N);
		for i = 1:N
			f(i) = f_measure(sCR{i}, idx, basis);
		end
		f = mean(f);
	elseif (isstruct(sCR))
		
        if size(sCR.confusion,1) > 2
            error('Cannot compute f-measure: more than two rows in confusion matrix');
        end
        
		prec = precision(sCR, basis);
        rec = recall(sCR, basis);
        f = (1+idx^2) * (prec*rec) / (idx^2 * prec + rec);
    else 
		f = 0;
	end
end
