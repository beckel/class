function [ household_quantiles ] = cer_get_consumption_quantiles(households, num_quantiles)

%         consumption_quartiles = get_consumption_quantiles(households, 4);

% store average consumption of each household
averages = cer_get_consumption_averages(households);

num_households = length(households);
household_quantiles = zeros(1, num_households);

quantiles = [ 0 quantile(averages, num_quantiles-1) ];

for h = 1:num_households
    q = max(find(averages(h) > quantiles));
    household_quantiles(h) = q;
end


