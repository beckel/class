function sClass = class_socialclass(option)
	if (nargin == 0)
		sClass.classes = { ...
			'AB', ...
			'C', ...
			'DE', ...
			};
		sClass.constr = { ...
			'Social_Class = 1', ...
			'Social_Class BETWEEN 2 AND 3', ...
			'Social_Class = 4', ...
			};
	elseif (nargin == 1)
		if (strcmp(option, 'name'))
			sClass = 'SocialClass';
		else
			error('This option is not supported');
		end
	end
end