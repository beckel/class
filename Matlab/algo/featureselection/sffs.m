function [sCR, sFSR] = sffs(sFS, figureOfMerit, num_features, log)

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

% This file was modified as part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich, 2012
% Author: Christian Beckel (beckel@inf.ethz.ch)

num_classes = length(sFS.classes);
D = size(sFS.samples{1}, 1);
k = 2;

log.normal('Feature selection using SFFS - %d features\n', num_features);

% Initialization
exact_number = 1;
[ sCR, sFSR ] = sfs(sFS, figureOfMerit, k, exact_number, log);
for i=1:k
    C{i} = sFSR.f_opt(1:i);
    X{i} = sFSR.feat_best(1:i)';
end

while k <= num_features
    
    %% Step I
    Ct = [];
    Y{D-k} = setdiff(1:D,X{k}, 'stable');
    for i = 1:length(Y{D-k})
        t = [X{k} Y{D-k}(i)];
        Ct = [Ct eval_algo(sFS, num_classes, t, figureOfMerit)];
    end
    [the_C, ind] = max(Ct);
    the_x = Y{D-k}(ind);
    X{k+1} = [X{k} the_x];
    log.debug('  Added %d - current set: ', the_x);
    log.write_comma_separated_list(X{k+1});
    log.debug(' - C: %f\n', the_C);

    %% Step II:Test
    Ct = [];
    for i = 1:length(X{k+1})
        t = setdiff(X{k+1}, X{k+1}(i), 'stable');
        Ct = [Ct eval_algo(sFS, num_classes, t, figureOfMerit)];
    end
    [J,r] = max(Ct);
    xr = X{k+1}(r);
    % check if (k+1)th feature is least significant compared to all other features
    if r == k+1
        % if so: leave it in the set and continue with next element
        C{k+1} = the_C;
        k = k+1;
        continue;
    end
    
    % if not: ??? why J < C{k}? Is this path ever reached?
    % isn't it endless loop if 'continue' is done?
    if r ~= k+1 & J < C{k}
        error('I thought this path was never reached');
        continue;
    end
    
    % exclude feature from set and continue with step I (don't go into step
    % III as no more features should be removed)
    if k==2
        X{k}=setdiff(X{k+1}, xr, 'stable');
        C{k}=J;
        tmp = X{k};
        log.debug('  Removed %d - current set: %d, %d', xr, tmp(1), tmp(2));
        log.debug(' - C: %f\n', J);
        continue;
    end
    X_hat{k}=setdiff(X{k+1}, xr, 'stable');
    log.debug('  Removed %d - Go to III\n', xr);
    
    %% Step III: Exclusion
    flag=1;
    while flag
        % find least significant feature in X
        Ct=[];
        for i=1:length(X_hat{k})
            t=setdiff(X_hat{k}, X_hat{k}(i), 'stable');
            Ct = [Ct eval_algo(sFS, num_classes, t, figureOfMerit)];
        end
        % J: fm when removing least significant feature
        % xs: least significant feature
        [J,s]=max(Ct);
        xs=X_hat{k}(s);
        
        % not worth it? go back to step I
        if J<C{k-1}
            X{k}=X_hat{k};
            C{k} = eval_algo(sFS, num_classes, X{k}, figureOfMerit);
            flag=0;
            log.debug('Current set: ');
            log.write_comma_separated_list(X{k});
            log.debug(' - C: %f\n', C{k});
            break;
        end
        
        % remove feature
        X_hat{k-1}=setdiff(X_hat{k},xs, 'stable');
        log.debug('  Removed %d - current set: ', xs);
        log.write_comma_separated_list(X_hat{k-1});
        k=k-1;
        if k==2
            X{k} = X_hat{k};
            C{k} = J;
            flag = 0;
            tmp = X{k};
            log.debug(' - C: %f\n', J);
        end
        log.debug(' - remain in III\n');
    end
    if flag==0
        continue;
    end
end

% wtf?
if k>num_features
    k=k-1;
end

% create optimal feature set
C{1} = 0;
[~, n_opt] = max(cell2mat(C));
feat_best = X{n_opt};
sCV = sFS;
for c = 1:num_classes
    sCV.samples{c} = sFS.samples{c}(feat_best,:);
end
[sCR, ~] = nfold_cross_validation(sCV, figureOfMerit);

sFSR.f_opt = cell2mat(C);
sFSR.feat_best = feat_best';

log.normal('Done with SFFS\n');

