function [t, distance] = classify_lda(sC)

    if (strcmp(sC, 'supports_distance'))
        t = 1;
        return;
    end
    
    [t, ~, ~, ~, ~, distance] = classify_distance_decision_boundary(sC.test_set', sC.training_set', sC.training_truth', 'linear');
	t = t';
end 