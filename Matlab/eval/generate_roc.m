% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)
function [ ROC, decision_boundary ] = generate_roc( sCR, basis, method )

    if iscell(sCR)
        posterior = cell(1,length(sCR));
        truth = cell(1, length(sCR));
        for i = 1:length(sCR)
            posterior{i} = sCR{i}.posterior';
            truth{i} = sCR{i}.truth;
        end
        posterior = cell2mat(posterior)';
        truth = cell2mat(truth);
    else
        posterior = sCR.posterior;
        truth = sCR.truth;
    end
    
    % number of classes
    C = size(posterior,2);
    
    if C == 2 && ~(strcmp(method, 'knn') == 1)
        include_decision_boundary = 1;
    else
        include_decision_boundary = 0;
    end
    
    % restructure posterior: "class in question" should be first
    posterior = [ posterior(:,basis), posterior(:, setdiff(1:C, basis)) ];
    
    % combine columns(2:end)
    posterior = [ posterior(:,1), sum(posterior(:,2:end), 2)];
    
    % sort households by distance to decision boundary
    [posterior, idc] = sortrows(posterior, -1);
    
    truth = truth(idc)';
    
%     num_class1 = sum(posterior(:,1) == 1);
%     posterior(1:num_class1,:) = sortrows(posterior(1:num_class1,:), -2);
%     posterior(num_class1+1:end,:) = sortrows(posterior(num_class1+1:end,:), 2);
    samples = posterior(:,1);

    % decision boundary
    if include_decision_boundary == 1
        decision_boundary_idx = find(samples < 0.5, 1, 'first');
    end
    
    FP = 0;
    TP = 0;
    R_x = [];
    R_y = [];
    dist_prev = -Inf;
    
    P = sum(truth == basis);
    N = sum(truth ~= basis);
        
    num_samples = size(samples,1);
    for j = 1:num_samples
        i = j;
        % this restriction is needed to avoid that samples with the same
        % distance are interpreted based on their in the data set.
        if samples(i) ~= dist_prev
            % push new point onto R
            R_x(end+1) = FP/N;
            R_y(end+1) = TP/P;
            dist_prev = samples(i);
        end
        
        if truth(i) == basis
            TP = TP + 1;
        else
            FP = FP + 1;
        end
        
        if include_decision_boundary == 1
            if j == decision_boundary_idx
                decision_boundary = [ R_x(end); R_y(end) ];
            end
        end
    end
    
    R_x(end+1) = FP/N;
    R_y(end+1) = TP/P;
    
    ROC = [ R_x; R_y ];
    
    if include_decision_boundary == 0
        decision_boundary = [ NaN; NaN ];
    end
end


