% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

clearvars;

load('data_raw');
load('questionnaire_ids');

% write day as integer (1: september 1st; 61: october 31st)
% idx = 0:length(data)-1;
% data(:,1) = mod(idx,61) + 1;

% remove missing data (i.e., ids that are all zeros)
% ids_to_delete = [ 10008782 ];
% idx = zeros(size(data,1),1);
% for i=1:length(ids_to_delete)
%     idx = idx + (data(:,2) == ids_to_delete(i));
% end
% data(logical(idx),:) = [];

%% remove beginning and end of the data
% 735113: saturday, september 1st
% 735114: sunday, september 2nd
% 735381: monday, may 27th
% 735382: tuesday, may 28th
% 735383: wednesday, may 29th
% 735384: thursday, may 30th
% 735385: friday, may 31st
days_to_delete = [ 735113, 735114, 735381, 735382, 735383, 735384, 735385 ];
idx = zeros(size(data,1),1);
to_delete = [];
for i=1:length(days_to_delete)
    day_to_delete = days_to_delete(i);
    first_col = data(:,1);
    to_delete = [ to_delete; find(first_col == day_to_delete) ];
end
data(to_delete,:) = [];

%% fix NaNs at the end (caused by clock change)
for i=1:size(data,1)
    if isnan(data(i,98))
        data(i,95:98) = data(i,91:94);
    end
end

%% separate data from questionnaires from rest
idx = zeros(size(data,1),1);
for i=1:length(questionnaire_ids)
    idx = idx + (data(:,2) == questionnaire_ids(i));
end
data_questionnaires = data(logical(idx),:);
data_non_questionnaires = data(logical(1-idx),:);

folder_name = 'data/issm/consumption/';
mkdir(folder_name);
save([folder_name, 'consumption_questionnaires.mat'], 'data_questionnaires');
save([folder_name, 'consumption_non_questionnaires.mat'], 'data_non_questionnaires');
save([folder_name, 'consumption_all.mat'], 'data');

%% Extract and store data matrix

first_day = datenum('2012-09-03');
last_day = datenum('2013-05-26');
num_days = last_day - first_day + 1;
num_households = length(questionnaire_ids);

data_matrix = zeros(num_households, num_days);
 
for i = 1:length(questionnaire_ids)
    id = questionnaire_ids(i);
    idx = data_questionnaires(:,2) == id;
    tmp = data_questionnaires(idx,:);
    
    % add each day of data to the corresponding fields of the data matrix
    for j = 1:size(tmp,1)
        current_day = tmp(j,1);
        col_start = (current_day - first_day) * 96 + 1;
        col_end = (current_day - first_day + 1) * 96;
    
        data_matrix(i, col_start:col_end) = tmp(j,3:98);
    end
    
end

save([folder_name, 'consumption_questionnaires_matrix'], 'data_matrix');
