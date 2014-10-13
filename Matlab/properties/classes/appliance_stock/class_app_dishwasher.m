% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_app_dishwasher(option)
	if (nargin == 0)
		sClass.classes = { ...
			'None', ...
			'>= 1', ...
			}; 
		sClass.constr = { ...
			'(PreTrial_Answers.Q82 = 1)', ...
			'(PreTrial_Answers.Q82 > 1)', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'App_Dishwasher';
		else
			error('This option is not supported');
		end
	end
end