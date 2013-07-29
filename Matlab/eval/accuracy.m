function f = accuracy(sCR)
	if (iscell(sCR))
		N = length(sCR);
		f = zeros(1,N);
		for i = 1:N
			f(i) = accuracy(sCR{i});
		end
		f = mean(f);
	elseif (isstruct(sCR))
		% Rate of correct decisions
		N = sum(sum(sCR.confusion));
		f = sum(diag(sCR.confusion)) / N; 
    else
		f = 0;
	end
end