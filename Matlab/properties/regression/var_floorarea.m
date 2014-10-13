% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function var = var_floorarea(option)
	if (nargin == 0)
        var.classes = { ...
			'Floor area', ...
			}; 
		var.constr = { ...
			'Floorsize_updated > 0', ...
			};
        var.value = { ...
            'Floorsize_updated', ...
            };
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			var = 'Floorarea';
		else
			error('This option is not supported');
		end
	end
end