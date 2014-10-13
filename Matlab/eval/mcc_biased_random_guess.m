% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = mcc_biased_random_guess(X)
	if (iscell(X))
		N = length(X);
        D = size(X{1}.confusion, 1);
		overall_cm = zeros(D);
		for i = 1:N
			overall_cm = overall_cm + X{i}.confusion;
        end
        x.confusion = overall_cm;
        f = mcc_biased_random_guess(x);
        
    elseif (isstruct(X))
        f = mcc_biased_random_guess(X.confusion);    
    else
        
        f = 0;
        D = size(X,1);
        distribution = (sum(X,1) ./ sum(sum(X)));
        X_new = zeros(D);
        
        for i=1:D
            X_new(i,:) = distribution * sum(X(i,:));
        end
        f = mcc(X_new);
    end
end
