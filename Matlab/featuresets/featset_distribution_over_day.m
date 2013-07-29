% Copyright: ETH Zurich, 12/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

function feat_set = featset_distribution_over_day(option)
	if (nargin == 0)
        feat_set = {...
            @day_distribution ...
        };
    elseif (nargin == 1)
		if (strcmp(option, 'name'))
			feat_set = 'featset_distribution_over_day';
		else
			error('This option is not supported');
		end
	end
end
