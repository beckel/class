% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_electric_shower_family_small(option)
	if (nargin == 0)
		sClass.classes = { ...
			'None', ...
			'>= 1', ...
			}; 
		sClass.constr = { ...
			'(PreTrial_Answers.Q83 = 1 AND UserProfile.Persons BETWEEN 1 AND 2)', ...
			'(PreTrial_Answers.Q83 > 1 AND UserProfile.Persons BETWEEN 1 AND 2)', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'App_Electric_Shower_Family_Small';
		else
			error('This option is not supported');
		end
	end
end