% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_waterheating(option)
	if (nargin == 0)
		sClass.classes = { ...
			'Electric', ...
			'NonElectric', ...
			}; 
		sClass.constr = { ...
			'(Water_Type = 2 OR Water_Type = 3)', ...
			'(Water_Type = 1 OR Water_Type BETWEEN 4 AND 6)', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'WaterHeating';
		else
			error('This option is not supported');
		end
	end
end