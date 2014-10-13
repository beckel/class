% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = precision(X, basis)
	if (iscell(X))
		N = length(X);
		D = size(X{1}.confusion, 1);
        overall_cm = zeros(D);
        for i = 1:N
            overall_cm = overall_cm + X{i}.confusion;
        end
        x.confusion = overall_cm;
        f = precision(x, basis);
    elseif (isstruct(X))
        f = precision(X.confusion, basis);
    else
        
        if size(X,1) > 2
            error('Cannot compute precision: more than two rows in confusion matrix');
        end
        
        if basis == 1
            f = X(1,1) / sum(X(:,1));
        else
            f = X(2,2) / sum(X(:,2));
        end
	end
end
