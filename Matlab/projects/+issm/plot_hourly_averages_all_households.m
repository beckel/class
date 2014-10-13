% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

load('consumption_questionnaires_matrix');
load('questionnaire_ids');

data_matrix;

num_households = size(data_matrix,1);
num_days = size(data_matrix,2) / 96;
num_hours = num_days * 24;

%% create hourly averages
hourly_averages = zeros(num_households, num_hours);
for i=1:num_households
    for j=1:num_hours
        hourly_averages(i,j) = mean(data_matrix(i, (j-1)*4+1 : j*4));
    end
end

%% mean for all households
hourly_averages_all_households = mean(hourly_averages, 1);

matrix_to_plot = zeros(num_days, 24);
for i=1:num_days
    matrix_to_plot(i,:) = hourly_averages_all_households((i-1)*24+1 : i*24);
end

%% plot 
imagesc(matrix_to_plot);
