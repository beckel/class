function [ t ] = get_truth_for_household(sD, id)
    for class = 1:length(sD.classes)
        households = sD.households{class};
        for h = 1:length(households)
            if households(h) == id
                t = sD.truth{class}(h);
                return;
            end
        end
    end
    t = -1;
end

