% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)
function [ ROC ] = generate_roc( sCR )

    distances = [];
    for n=1:length(sCR)
        distances = [ distances; sCR{n}.distance ];
    end
    
    % sort households by distance to decision boundary
    distances = sortrows(distances, 1);
    num_class1 = sum(distances(:,1) == 1);
    distances(1:num_class1,:) = sortrows(distances(1:num_class1,:), -2);
    distances(num_class1+1:end,:) = sortrows(distances(num_class1+1:end,:), 2);
    samples = distances;

    FP = 0;
    TP = 0;
    R_x = [];
    R_y = [];
    dist_prev = -Inf;
    P = sum(samples(:,3) == 1);
    N = sum(samples(:,3) == 2);
    
    num_samples = size(samples,1);
    for i = 1:num_samples
        
        % this restriction is needed to avoid that samples with the same
        % distance are interpreted based on their in the data set.
        if samples(i,2) ~= dist_prev
            % push new point onto R
            R_x(end+1) = FP/N;
            R_y(end+1) = TP/P;
            dist_prev = samples(i,2);
        end
        
        if samples(i,3) == 1
            TP = TP + 1;
        else
            FP = FP + 1;
        end
    end
    
    R_x(end+1) = FP/N;
    R_y(end+1) = TP/P;
    
    ROC = [ R_x; R_y ];
    
%     plot(R_x, R_y)
end


