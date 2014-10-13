% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

% ylabel style = {yshift=0.5cm},

connection = cer_db_get_connection();
select = 'UserProfile.id';
from = 'PreTrial_Answers INNER JOIN UserProfile ON PreTrial_Answers.ID = UserProfile.ID';
orderby = 'ID';
cer_ids;
where = { ...
   'UserProfile.Type BETWEEN 1 AND 3', ...
};
query = query_builder(select, from, where, orderby);
fprintf('%s\n', query);
curs = fetch(exec(connection, query));
ids = cell2mat(curs.data(:,1));
[ids, ia, ~] = intersect(ids, setdiff(union(type1, type3), exclude));
close(connection);

%% init variables
num_households = length(ids)
num_weeks = 75;
num_days = num_weeks * 7;
data_matrix = zeros(num_days, 48);
occurance_matrix = zeros(num_days, 1);

for i = 1:num_households
   load(['data/cer_ireland/weekly_traces/', num2str(ids(i))]);
    data = Consumer.consumption;
     weeks = [ 1 : num_weeks ];
%    weeks = [ 14:22, 25:33 ];
%    weeks = [ 26:30 ];
    for j = weeks
        for k = 1:7
            start = (k-1)*48+1;
            stop = k*48;
            tmp_consumption = data(j, start:stop);
            
            if sum(tmp_consumption == 0) > 10
                continue;
            end
            
            matrix_idx = 7*(j-1)+k;
            data_matrix(matrix_idx, :) = data_matrix(matrix_idx, :) + tmp_consumption;
            occurance_matrix(matrix_idx) = occurance_matrix(matrix_idx) + 1;
        end
    end
    fprintf('Done with household %d - Remaining: %d\n', i, num_households-i);
end

%% mean for all households
mean_data_matrix = zeros(size(data_matrix, 1), size(data_matrix, 2));
for i = 1:size(mean_data_matrix, 1)
    mean_data_matrix(i,:) = data_matrix(i,:) ./ occurance_matrix(i);
end
mean_data_matrix(isnan(mean_data_matrix)) = 0;

%% plot 
clear title xlabel ylabel;

fig = figure('Color', [1 1 1]);
imagesc(mean_data_matrix);

xticks = get(gca, 'XTick') / 2 / 24;
set(gca, 'XTickLabel', datestr(xticks, 'HH:MM'));

yticks = get(gca, 'YTick') + datenum('2009-07-20');
set(gca, 'YTickLabel', datestr(yticks, 'dd.mm.yy'));

% title('Aggregated 30-minute consumption of all households');
title('');

fontsize = 8;
fontname = 'Times';

title = get(gca, 'title');
set(title, 'FontSize', fontsize);
set(title, 'FontName', fontname);
set(gca, 'title', title);

% set(gca, 'FontSize', fontsize);
% set(gca, 'FontName', fontname);

xlabel('Time of day', 'FontSize', fontsize, 'FontName', fontname);
ylabel('Date', 'FontSize', fontsize, 'FontName', fontname);
    
colorbar('YTickLabel', {'0.2 kW', '0.4 kW', '0.6 kW', '0.8 kW', '1.0 kW', '1.2 kW'});

fig = make_report_ready(fig, 'size', 'consumption_overview');
   
% fprintf(num2str(xticks* 24))
xticks = [ 10 20 30 40 ];
% get(gca, 'XTick');
set(gca, 'XTick', xticks);
set(gca, 'XTickLabel', datestr(xticks/2/24, 'HH AM'));

% yticks = [ 50 100 150 200 250 300 350 400 450 500 ] + datenum('2009-07-20');
yticks = [ 100 200 300 400 500 ] + datenum('2009-07-20');
% yticks = get(gca, 'YTick') + datenum('2009-07-20');
set(gca, 'YTickLabel', datestr(yticks, 'dd.mm.yy'));

% save file
filename = 'semihour_averages_all_households';
folder = 'projects/+energy/+images/semihour_averages_all_households/';
if exist(folder, 'dir') == 0
    mkdir(folder);
end
% saveas(fig, [folder, filename, '.eps'], 'psc2');
print('-depsc2', '-cmyk', '-r2400', [folder, filename, '.eps']);
saveas(fig, [folder, filename, '.png'], 'png');
matlab2tikz([folder, filename, '.tikz'], 'height', '\figureheight', 'width', '\figurewidth');
pause(1);
close(fig);

