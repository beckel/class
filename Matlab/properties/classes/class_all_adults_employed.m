% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

function sClass = class_all_adults_employed(option)
	if (nargin == 0)
		sClass.classes = { ...
			'AllAdultsEmployed', ...
			'NotAllAdultsEmployed', ...
			};
		sClass.constr = { ...
			'Adults_Post > 0 AND NumberEmployed_Post >= Adults_Post', ...
			'Adults_Post > 0 AND NumberEmployed_Post < Adults_Post', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'All_Adults_Employed';
		else
			error('This option is not supported');
		end
	end
end