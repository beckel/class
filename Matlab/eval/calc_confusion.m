function confusion = calc_confusion(truth, prediction, C)
	confusion = zeros(C,C);
	for tr = 1:C
		for pr = 1:C
			confusion(tr,pr) = sum(and(truth == tr, prediction == pr));
		end
	end
end