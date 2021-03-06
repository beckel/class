% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_age(option)
	if (nargin == 0)
		sClass.classes = { ...
			'<35', ...
			'35-65', ...
			'65+', ...
			};
		sClass.constr = { ...
			'Age BETWEEN 1 AND 2', ...
			'Age BETWEEN 3 AND 5', ...
			'Age = 6', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'Age';
		else
			error('This option is not supported');
		end
	end
end
