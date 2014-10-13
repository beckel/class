% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function var = var_income(option)
	if (nargin == 0)
        var.classes = { ...
			'Class of Income', ...
			}; 
		var.constr = { ...
			'(Income BETWEEN 1 AND 5)', ...
			};
        var.value = { ...
            'Income', ...
            };
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			var = 'Income';
		else
			error('This option is not supported');
		end
	end
end