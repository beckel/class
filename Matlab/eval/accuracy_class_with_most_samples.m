% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = accuracy_class_with_most_samples(X)
	if (iscell(X))
		N = length(X);
        D = size(X{1}.confusion, 1);
		overall_cm = zeros(D);
		for i = 1:N
			overall_cm = overall_cm + X{i}.confusion;
        end
        x.confusion = overall_cm;
        f = accuracy_class_with_most_samples(x);
        
    elseif (isstruct(X))
        f = accuracy_class_with_most_samples(X.confusion);    
    else
        
        f = 0;
        for i=1:size(X,1)
            tmp = sum(X(i,:)) / sum(sum(X));
            f = max(f, tmp);
        end
	end
end


        
        
        


