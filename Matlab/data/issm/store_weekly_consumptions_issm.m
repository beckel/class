% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% create weekly traces - run this after Matlab files have been generated
% from the CSV file using the clean_data script.

clc;
close all;
clearvars;

load('data/issm/consumption/consumption_all');

dest_folder = 'data/issm/weekly_traces/';
mkdir(dest_folder);

ids = unique(data(:,2));

for i = 1:length(ids)
    id = ids(i);
    
    data_household = data(data(:,2) == id, :);
    num_weeks = 69; % size(data_household, 1) / 7;
    data_household_new = zeros(num_weeks, 96*7);
     
    days_to_store = size(data_household, 1);
    for j = 1:days_to_store
        current_day = data_household(j,1);
        first_day = 735115;
        diff = current_day - first_day;
        dest_col_start = mod(diff,7) * 96 + 1;
        dest_col_stop = mod(diff,7) * 96 + 96;
        dest_row = floor(diff/7) + 1;

        data_household_new(dest_row,dest_col_start:dest_col_stop) = data_household(j,3:98);
    end
        
    Consumer = [];
    Consumer.id = id;
    Consumer.consumption = data_household_new;

  	fprintf('ID: %i, %i weeks extracted.\n', id, num_weeks);

  	save([dest_folder, num2str(id)], 'Consumer');

    clear data_household_new;

end
