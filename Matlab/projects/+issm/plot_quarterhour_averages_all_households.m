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

%% mean for all households
mean_data_matrix = mean(data_matrix, 1);
matrix_to_plot = zeros(num_days, 96);
for i=1:num_days
    matrix_to_plot(i,:) = mean_data_matrix((i-1)*96+1 : i*96);
end

%% plot 
clear title xlabel ylabel;

fig = figure('Color', [1 1 1]);
imagesc(matrix_to_plot);

xticks = get(gca, 'XTick') / 4 / 24;
set(gca, 'XTickLabel', datestr(xticks, 'HH:MM'));

yticks = get(gca, 'YTick') + datenum('2012-09-03');
set(gca, 'YTickLabel', datestr(yticks, 'dd.mm.'));

title('Aggegierter 15-Minuten-Verbrauch aller Haushalte');

fontsize = 14;
fontname = 'Times';

set(gca, 'FontSize', fontsize);
set(gca, 'FontName', fontname);

xlabel('Tageszeit', 'FontSize', fontsize, 'FontName', fontname);
ylabel('Datum', 'FontSize', fontsize, 'FontName', fontname);

title = get(gca, 'title');
set(title, 'FontSize', fontsize);
set(title, 'FontName', fontname);
set(gca, 'title', title);
    
set(gca,'linewidth',2) 

% save file
filename = 'quarterhour_averages_all_households';
folder = 'projects/+issm/images/';
mkdir(folder);
saveas(fig, [folder, filename, '.eps'], 'psc2');
pause(1);
close(fig);

