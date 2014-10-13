% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

load('consumption_questionnaires_matrix');
load('questionnaire_ids');

data_matrix;

num_households = size(data_matrix,1);
num_days = size(data_matrix,2) / 96;

% create daily averages
daily_averages = zeros(num_households, num_days);
for i=1:num_households
    for j=1:num_days
        daily_averages(i,j) = mean(data_matrix(i, (j-1)*96+1 : j*96));
    end
end

% normalize
daily_averages_normalized = daily_averages;
for i=1:num_households
    tmp = daily_averages(i,:);
    daily_averages_normalized(i,:) = tmp ./ max(tmp);
end

imagesc(daily_averages_normalized);