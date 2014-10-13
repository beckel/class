% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function var = var_age(option)
	if (nargin == 0)
		var.classes = { ...
			'Age HoH', ...
			}; 
		var.constr = { ...
			'Age BETWEEN 1 AND 6', ...
			};
        var.value = { ...
            'Age', ...
            };      

	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			var = 'Age';
		else
			error('This option is not supported');
		end
	end
end
