% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_usage_computers_gameconsole(option)
	if (nargin == 0)
		sClass.classes = { ...
			'Low', ...
			'High', ...
			}; 
		sClass.constr = { ...
			'(PreTrial_Answers.Q114 = 1)', ...
			'(PreTrial_Answers.Q114 > 1)', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'Usage_Computers_Gameconsole';
		else
			error('This option is not supported');
		end
	end
end