function prec = precision(sCR, basis)
	if (iscell(sCR))
		N = length(sCR);
		prec = zeros(1,N);
		for i = 1:N
			prec(i) = precision(sCR{i}, basis);
		end
		prec = mean(prec);
	elseif (isstruct(sCR))
		
        if size(sCR.confusion,1) > 2
            error('Cannot compute precision: more than two rows in confusion matrix');
        end
        
        if basis == 1
            prec = sCR.confusion(1,1) / sum(sCR.confusion(:,1));
        else
            prec = sCR.confusion(2,2) / sum(sCR.confusion(:,2));
        end
    else 
		prec = 0;
	end
end
