function sClass = class_lightbulbs(option)
	if (nargin == 0)
		sClass.classes = { ...
			'Lightbulbs', ...
			'ESL', ...
			};
		sClass.constr = { ...
			'Lighting < 3 ', ...
			'Lighting > 2', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'Lightbulbs';
		else
			error('This option is not supported');
		end
	end
end