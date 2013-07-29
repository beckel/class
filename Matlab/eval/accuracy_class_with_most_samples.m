function f = accuracy_class_with_most_samples(sCR)
	if (iscell(sCR))
		N = length(sCR);
		f = zeros(1,N);
		for i = 1:N
            confusion = sCR{i}.confusion;
            for j=1:size(confusion,1)
                tmp = sum(confusion(j,:)) / sum(sum(confusion));
                f(i) = max(f(i),tmp);
            end
		end
		f = mean(f);
    elseif (isstruct(sCR))
		% Rate of correct decisions
        f = 0;
        for i=1:size(sCR.confusion,1)
            tmp = sum(sCR.confusion(i,:)) / sum(sum(sCR.confusion));
            f = max(f, tmp);
        end
	else
		f = 0;
	end
end