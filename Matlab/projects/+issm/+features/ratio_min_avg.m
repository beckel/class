% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% minimum consumption / average consumption
function feature = ratio_min_avg(consumption)
    if strcmp(consumption, 'reference')
        feature = 0;
    elseif (strcmp(consumption, 'dim'))
		feature = 7;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 96 + 1;
            stop = (i-1) * 96 + 96;
            indices = start : stop;
            feature(i) = min(consumption(indices)) / mean(consumption(indices));

            % 0/0
%             if isnan(feature(i))
%                  feature(i) = 1;
%             end
            
            feature(i) = sqrt(feature(i));
        end
                
    end
end 