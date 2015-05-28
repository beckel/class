function [sFSR] = sffs(sFS, figureOfMerit, num_features, log)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION
%  [cLbest,maxJ]=SequentialForwardFloatingSelection(class1,class2,CostFunction,NumFeatComb);
%  Feature vector selection by means of the Sequential Forward Floating
%  Selection technique, given the desired number of features in the best combination.
%
% INPUT ARGUMENTS:
%   class1:         matrix of data for the first class, one pattern per column.
%   class2:         matrix of data for the second class, one pattern per column.
%   CostFunction:   class separability measure.
%   NumFeatComb:    desired number of features in best combination.
%
% OUTPUT ARGUMENTS:
%   cLbest:         selected feature subset. Vector of row indices.
%   maxJ:           value of the class separabilty measure.
%
% (c) 2010 S. Theodoridis, A. Pikrakis, K. Koutroumbas, D. Cavouras
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%
% This file was modified as part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich, 2012
% Author: Christian Beckel (beckel@inf.ethz.ch)
% Changes: 
% * Added log output
% * Adapted to CLASS input/output parameters
% * Fixed bug: (X_hat{k}=setdiff(X{k+1}, xr); must be before part III
% * Added logkeeping to avoid endless loops
% * Leave sets unsorted 
% * Return n <= num_features features depending on C instead of num_features fixed.
%%%%%

num_features = 7;
% num_features = 5;
% num_features = 3;

%% Process input data and run SFS for k=2 in order to get started
num_classes = length(sFS.classes);

% Number of features
D = size(sFS.samples{1}, 1);
if num_features >= D
    num_features = D-1;
end
    
% Delta in the figure of merit that is needed to remove a feature instead
% of adding the next one
delta = 0.005;

% Number of features to begin with (SFS)
k = 2;
log.normal('Feature selection using SFFS - %d features\n', num_features);
exact_number = 1;
[ sCR, sFSR ] = sfs(sFS, figureOfMerit, k, exact_number, log);

if D <= 2
    sFSR.fm_training = sFSR.fm_opt;
    sFSR.features = sFSR.features;
    sFSR.fm_opt = [];  
    return;
end

for i=1:k
    C{i} = sFSR.fm_opt(i);
    X{i} = sFSR.features(1:i)';
end

%% Initialize logbook to remember states already visited
logbook = Logbook(num_features+1);
logbook.add(X{k});

%% Search for features
while k <= num_features
    
    % log state as "visited"
    logbook.add(X{k});
    
    %% Step I: Add feature that improves figure of merit most
    Ct = [];
    Y{D-k} = setdiff(1:D,X{k}, 'stable');
    for i = 1:length(Y{D-k})
        t = [X{k} Y{D-k}(i)];
        tmp = eval_algo(sFS, num_classes, t, figureOfMerit);
        Ct = [Ct tmp];
        log.debug('Feature %d: %f\n', i, tmp);

    end
    [the_C, ind] = max(Ct);
    the_x = Y{D-k}(ind);
    X{k+1} = [X{k} the_x];
    log.debug('  Added %d - current set: ', the_x);
    log.write_comma_separated_list(X{k+1});
    log.debug(' - C: %f\n', the_C);

    %% Step II: Test if removal of single feature improves figure of merit
    Ct = [];
    for i = 1:length(X{k+1})
        t = setdiff(X{k+1}, X{k+1}(i), 'stable');
        % Only remove feature if its removal does not lead to a state
        % already visited
        if logbook.contains(t) == 1 && i ~= length(X{k+1})
            Ct = [Ct, -1];
        else
            Ct = [Ct eval_algo(sFS, num_classes, t, figureOfMerit)];
        end
    end
    Ct(end) = Ct(end) + delta;
    [J,r] = max(Ct);
    xr = X{k+1}(r);
    % If (k+1)th feature is least significant compared to all others, 
    % leave it in the set and continue with Step I.
    if r == k+1
        C{k+1} = the_C;
        k = k+1;
        continue;
    end
    
    % If (k+1)th feature is NOT least significant but removal doesn't
    % improve figure of merit: Do not remove feature, continue with Step I.
    if r ~= k+1 & J < C{k}
        log.debug('  Removing feature %d does not improve C{k} - continue.\n', xr);
        k = k+1;
        continue;
    end
    
    % If only two features are left, exclude feature from set and continue 
    % with step I
    if k==2
        X{k}=setdiff(X{k+1}, xr, 'stable');
        C{k}=J;
        tmp = X{k};
        log.debug('  Removed %d - current set: %d, %d', xr, tmp(1), tmp(2));
        log.debug(' - C: %f\n', J);
        continue;
    end
    log.debug('  Removed %d in step II - Go to Step III\n', xr);
    
    %% Step III: Exclusion of more features (backtracking)
    X_hat{k}=setdiff(X{k+1}, xr, 'stable');
    % logbook.add(X_hat{k});
    flag=1;
    while flag
        % Remove least significant feature in X (unless its removal leads
        % to a state that has already been visited)
        Ct=[];
        for i=1:length(X_hat{k})
            t=setdiff(X_hat{k}, X_hat{k}(i), 'stable');
            if logbook.contains(t) == 1
                Ct = [Ct, -1];
            else
                Ct = [Ct eval_algo(sFS, num_classes, t, figureOfMerit)];
            end
        end
        [J,s]=max(Ct);
        xs=X_hat{k}(s);
        
        % If its removal does not improve figure of merit, go back to 
        % Step I.
        if J<C{k-1}
            X{k}=X_hat{k};
            C{k} = eval_algo(sFS, num_classes, X{k}, figureOfMerit);
            flag=0;
            log.debug('Back to step I - Current set: ');
            log.write_comma_separated_list(X{k});
            log.debug(' - C: %f\n', C{k});
            break;
        end
        
        % If its removal does improve figure of merit, remove feature and
        % continue with backtracking.
        X_hat{k-1}=setdiff(X_hat{k},xs, 'stable');
        log.debug('  Removed %d - current set: ', xs);
        log.write_comma_separated_list(X_hat{k-1});
        k=k-1;
        if k==2
            X{k} = X_hat{k};
            C{k} = J;
            flag = 0;
            log.debug(' - C: %f', J);
        end
        log.debug(' - Remain in III\n');
    end
    if flag==0
        continue;
    end
end

if k>num_features
    k=k-1;
end

%% Output: Best feature set found
[~, n_opt] = max(cell2mat(C));
features = X{n_opt};
fm_opt = cell2mat(C);

sFSR.fm_training = fm_opt(1:length(features))';
sFSR.features = features';
sFSR.fm_opt = [];

log.normal('Done with SFFS\n');

end
