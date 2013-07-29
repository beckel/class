function rec = recall(sCR, basis)
	if (iscell(sCR))
		N = length(sCR);
		rec = zeros(1,N);
		for i = 1:N
			rec(i) = recall(sCR{i}, basis);
		end
		rec = mean(rec);
	elseif (isstruct(sCR))
		
        if size(sCR.confusion,1) > 2
            error('Cannot compute recall: more than two rows in confusion matrix');
        end
        
        if basis == 1
            rec = sCR.confusion(1,1) / sum(sCR.confusion(1,:));
        else
            rec = sCR.confusion(2,2) / sum(sCR.confusion(2,:));
        end
	else
		rec = 0;
	end
end
