% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function f = mcc(X)
	
if (iscell(X))
		N = length(X);
        D = size(X{1}.confusion, 1);
        overall_cm = zeros(D);
		for i = 1:N
            overall_cm = overall_cm + X{i}.confusion;
        end
   
        x.confusion = overall_cm;
        f = mcc(x);

	elseif (isstruct(X))
        f = mcc(X.confusion);
    
else
    
    % Formula (8) of 
    % "Comparing two K-category assignments by a K-category correlation
    %  coefficient"
    
    C = X;
    N = sum(sum(C));
    D = size(C,1);
    
    numerator1 = sum(N) * trace(C);
    
    numerator2 = 0;
    for k = 1:D
        for l = 1:D
            numerator2 = numerator2 + C(k,:) * C(:,l);
        end
    end
    
    tmp = 0;
    for k = 1:D
        for l = 1:D
            Ct = C';
            tmp = tmp + C(k,:) * Ct(:,l);
        end
    end
    denominator1 = N*N - tmp;
    
    tmp = 0;
    for k = 1:D
        for l = 1:D
            Ct = C';
            tmp = tmp + Ct(k,:) * C(:,l);
        end
    end
    denominator2 = N*N - tmp;
    
    f = (numerator1 - numerator2) / (sqrt(denominator1)*sqrt(denominator2));
    
%         mccs = [];
%         D = size(X, 1);
%         for i = 1:D
% 
%             X2 = two_submatrix(X, i);
%             TP = X2(1,1);
%             TN = X2(2,2);
%             FP = X2(2,1);
%             FN = X2(1,2);
%             enumerator = TP*TN - FP*FN;
%             denominator = sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN));
%             
%             if denominator == 0
%                 tmp_mcc = 0;
%             else
%                 tmp_mcc = enumerator/denominator;
%             end
%             mccs = [ mccs, tmp_mcc ];
%         end
%         
%         f = mean(mccs);
	end
end