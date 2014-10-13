function [ distances_new, distances_household_order_preserved ] = get_distances_by_label( sCR, labels )
%GET_DISTANCES_BY_LABEL Returns a vector of distances for each household
%based on the distance to the decision boundary characterized by the
%label(s).

    % put households with matching prediction label first
    distances = sCR.distance;
    distances(:,end+1) = sCR.households;
    distances = sortrows(distances, 1);
    idc = ismember(distances(:,1), labels);
    
    true = sum(idc);
    false = sum(~idc);
    distances_new = sortrows(distances(idc,:), -2);
    distances_new(true+1:size(distances,1),:) = sortrows(distances(~idc,:), 2);
    distances_new(true+1:size(distances,1),2) = -1 * distances_new(true+1:size(distances,1),2);
    
    %% NOW distances represents a vector sorted by distance. This is good for some applications - however, here we require a specific household order:
    distances_household_order_preserved = zeros(1, length(sCR.households));
    for h = 1:length(sCR.households)
        household = sCR.households(h);
        idx = find(distances_new(:,4) == household);
        distances_household_order_preserved(h) = distances_new(idx, 2);
    end
    
end

