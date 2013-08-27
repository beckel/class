% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_eheating(option)
	if (nargin == 0)
		sClass.classes = { ...
			'e-Heating', ...
			'Other', ...
			};
		sClass.constr = { ...
			'(Heat_Type BETWEEN 1 AND 2) OR (Water_Type BETWEEN 2 AND 3)', ...
			'NOT((Heat_Type BETWEEN 1 AND 2) OR (Water_Type BETWEEN 2 AND 3))', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'eHeating';
		else
			error('This option is not supported');
		end
	end
end