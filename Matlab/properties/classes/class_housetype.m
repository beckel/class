% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_housetype(option)
	if (nargin == 0)
		sClass.classes = { ...
			'Detached or Bungalow', ...
			'Semi-Detatched or Terraced', ...
			};
		sClass.constr = { ...
			'House_Type = 3 OR House_Type = 5', ...
			'House_Type = 2 OR House_Type = 4', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'HouseType';
		else
			error('This option is not supported');
		end
	end
end
