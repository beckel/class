function [sCR, sFSR] = sffs(sFS, figureOfMerit, num_features)

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

num_classes = length(sFS.classes);
D = size(sFS.samples{1}, 1);
k = 2;

% Initialization
[ sCR, sFSR ] = sfs(sFS, figureOfMerit, k);
C{k} = sFSR.f_opt(k);
X{k} = sFSR.feat_best';

%[X{k}, C{k}] = ret1.

while k <= num_features
    
    fprintf('\nSFFS: %d of %d features\n', k, num_features);
    
    %% Step I
    Ct = [];
    Y{D-k} = setdiff(1:D,X{k});
    for i = 1:length(Y{D-k})
        t = [X{k} Y{D-k}(i)];
        Ct = [Ct eval_algo(sFS, num_classes, t, figureOfMerit)];
    end
    [the_C, ind] = max(Ct);
    the_x = Y{D-k}(ind);
    X{k+1} = [X{k} the_x];
    
    %% Step II:Test
    Ct = [];
    for i = 1:length(X{k+1})
        t = setdiff(X{k+1}, X{k+1}(i));
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
        X{k}=setdiff(X{k+1},xr);
        C{k}=J;
        continue;
    end
    X_hat{k}=setdiff(X{k+1},xr);
    
    %% Step III: Exclusion
    flag=1;
    while flag
        % find least significant feature in X
        Ct=[];
        for i=1:length(X_hat{k})
            t=setdiff(X_hat{k}, X_hat{k}(i));
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
            break;
        end
        
        % remove feature
        X_hat{k-1}=setdiff(X_hat{k},xs);
        k=k-1;
        if k==2
            X{k} = X_hat{k};
            C{k} = J;
            flag = 0;
        end
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
