% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function feat_set = feature_set_daily(option)
	if (nargin == 0)
		feat_set = {...
                    @cons_day_avg, ...
                    @cons_day_weekday_avg, ...
                    @cons_weekday_avg, ...
                    @cons_weekend_avg, ...
                    @ratio_workday_weekend, ...
		};
 	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			feat_set = 'all';
		else
			error('This option is not supported');
		end
	end
end