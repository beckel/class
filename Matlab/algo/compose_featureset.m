% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

%% Generates a Feature Set
%	consumption:	Consumption Data
%	feature_funcs:	Cell array of Feature Function handles
function feat_vec = compose_featureset(consumption, feature_funcs, reference)
	if (strcmp(consumption, 'dim'))
		feat_vec = 0;
		for i = 1:length(feature_funcs)
			feat_vec = feat_vec + feature_funcs{i}('dim');
		end
	else
		feat_vec = [];
		d = 1;
		for i = 1:length(feature_funcs)
            tmp_consumption = consumption;
			D = feature_funcs{i}('dim');
            % check input dimension required by feature
            input_dim = feature_funcs{i}('input_dim');
            if input_dim < length(consumption)
                sampling_factor = length(consumption) / input_dim;
                tmp_consumption = mean(reshape(consumption, sampling_factor, []), 1);
            elseif input_dim > length(consumption)
                error('Feature %s requires a higher input dimension\n', feature_funcs{i});
            end

            if feature_funcs{i}('reference') == 0
                feat_vec(d:d+D-1, 1) = feature_funcs{i}(tmp_consumption);
            else
                feat_vec(d:d+D-1, 1) = feature_funcs{i}(tmp_consumption, reference);
            end
			d = d + D;
		end
	end
end