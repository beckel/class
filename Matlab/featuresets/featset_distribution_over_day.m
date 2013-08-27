% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function feat_set = featset_distribution_over_day(option)
	if (nargin == 0)
        feat_set = {...
            @day_distribution ...
        };
    elseif (nargin == 1)
		if (strcmp(option, 'name'))
			feat_set = 'featset_distribution_over_day';
		else
			error('This option is not supported');
		end
	end
end
