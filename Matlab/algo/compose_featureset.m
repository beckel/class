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
			feat_vec(d:d+D-1, 1) = feature_funcs{i}(consumption);
			d = d + D;
		end
	end
end