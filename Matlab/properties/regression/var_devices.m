% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function var = var_devices(option)
	if (nargin == 0)
        var.classes = { ...
			'No. of Devices (Appliances + Entertainment)', ...
			}; 
		var.constr = { ...
			'(Appliances > 0 AND Entertainment > 0)', ...
			};
        var.value = { ...
            'Devices', ...
            };        
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			var = 'Devices';
		else
			error('This option is not supported');
		end
	end
end