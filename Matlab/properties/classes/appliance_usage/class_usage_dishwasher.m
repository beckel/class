% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_usage_dishwasher(option)
	if (nargin == 0)
		sClass.classes = { ...
			'Less than 1 load/day', ...
			'One or more loads per day', ...
			}; 
		sClass.constr = { ...
			'(PreTrial_Answers.Q102 = 1)', ...
			'(PreTrial_Answers.Q102 > 1)', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'Usage_Dishwasher';
		else
			error('This option is not supported');
		end
	end
end