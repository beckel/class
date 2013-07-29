function ind = logic2ind(logic)
	N = size(logic,1);
	ind = zeros(N,max(sum(logic,2)));
	for i = 1:N
		idx = find(logic(i,:) == true);
		ind(i,1:length(idx)) = idx;
	end
end