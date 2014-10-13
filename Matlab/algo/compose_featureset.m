% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

%% Generates a Feature Set
%	consumption:	Consumption Data
%	feature_funcs:	Cell array of Feature Function handles
function feat_vec = compose_featureset(consumption, feature_funcs)
	if (strcmp(consumption, 'dim'))
		feat_vec = 0;
		for i = 1:length(feature_funcs)
			feat_vec = feat_vec + feature_funcs{i}('dim');
		end
	else
		feat_vec = [];
		d = 1;
		for i = 1:length(feature_funcs)
            D = feature_funcs{i}('dim');
            % tmp_consumption = mean(reshape(consumption, sampling_factor, []), 1);
            feat_vec(d:d+D-1, 1) = feature_funcs{i}(consumption);
			d = d + D;
		end
	end
end