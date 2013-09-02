% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% ratio between this particular week and the average summer consumption
% during 17-20h
% 'consumption': consumption over 1 week
% 'reference_consumption': some reference (e.g., a value or vector to compare
% the consumption with
function feature = summer_winter_evening_cons(consumption, reference)
    if strcmp(consumption, 'reference')
        feature = 1;
    elseif (strcmp(consumption, 'dim'))
		feature = 1;
	elseif (strcmp(consumption, 'input_dim'))
        feature = 96*7;
    else
        if length(reference) ~= 7*96
            error('Wrong dimension of "reference" - exptected 96 values\n');
        end
        
        this_week = zeros(7,1);
        ref_val = zeros(7,1);
        for i=1:7
            % 17h - 20h (3 hours)
            start = (i-1) * 96 + 65;
            stop = (i-1) * 96 + 76;
            
            indices = start : stop;
        
            this_week(i) = mean(consumption(indices));
            ref_val(i) = mean(reference(indices));
        end
        
        feature = mean(this_week) - mean(ref_val);
        
    end
end

   