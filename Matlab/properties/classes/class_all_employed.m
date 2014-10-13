% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_all_employed(option)
	if (nargin == 0)
		sClass.classes = { ...
			'AllEmployed', ...
			'NotAllEmployed', ...
			};
		sClass.constr = { ...
			'Persons_Post > 0 AND NumberEmployed_Post = Persons_POST', ...
			'Persons_Post > 0 AND NumberEmployed_Post < Persons_POST', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'All_Employed';
		else
			error('This option is not supported');
		end
	end
end