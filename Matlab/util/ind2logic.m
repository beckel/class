function logic = ind2logic(ind, C)
	N = size(ind,1);
	logic = false([N,C]);
	for i = 1:N
		l = false([1, C]);
		l(ind(i,:)) = true;
		logic(i,:) = l;
	end
end