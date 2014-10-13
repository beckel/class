% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = f_measure(X, idx, basis)
    if nargin < 3
        error('Not enough input arguments');
    end
    
    if (iscell(X))
    	N = length(X);
		D = size(X{1}.confusion, 1);
        overall_cm = zeros(D);
        for i = 1:N
            overall_cm = overall_cm + X{i}.confusion;
        end
        x.confusion = overall_cm;
        f = f_measure(x, idx, basis);
    elseif (isstruct(X))
        f = f_measure(X.confusion, idx, basis);
    else
        if size(X,1) > 2
            error('Cannot compute f-measure: more than two rows in confusion matrix');
        end
        
		prec = precision(X, basis);
        rec = recall(X, basis);
        f = (1+idx^2) * (prec*rec) / (idx^2 * prec + rec);
	end
end
