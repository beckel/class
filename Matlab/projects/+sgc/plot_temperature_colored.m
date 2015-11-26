% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

clearvars;

folder = '/Users/beckel/Documents/Paper/2015-05-SmartGridComm/figures/';
if exist(folder, 'dir') == 0
    mkdir(folder);
end

% cer_ids;
% ids = setdiff(union(type1, type3), exclude);

% plotting
width = 9.5;
height = 5.5;
fontsize = 8;

% N = length(ids);
% weeks = 1:75;
% 
% %% average consumption of each household
% avg_cons = zeros(1, N);
% num_weeks = length(weeks);
% for i = 1:N
%     fprintf('Household no. %d of %d\n', i, N);
%     id = ids(i);
%     Consumer = get_weekly_consumption(id, 'cer_ireland');
%     sum_cons = 0;
%     num_cons = 0;
%     for w = 1:num_weeks
%         week = weeks(w);
%         weekly_trace = Consumer.consumption(week, :);
%         if sum(weekly_trace == 0) > 10
%            continue;
%         end
%         
%         sum_cons = sum_cons + mean(weekly_trace);
%         num_cons = num_cons + 1;
%     end
%     avg_cons(i) = sum_cons / num_cons * 24;
% end

%% temperature coefficient
load('temperature_and_daylight_variables.mat');
temperature_coefficients = temperature_and_daylight_variables(:,4);

% Heating characteristics
[ID,Q41,Q42,Q43,Q44,Q45,Q46,Q47] = import_heating('heating_characteristics.csv');

coefficient_central_electric = temperature_coefficients(boolean(Q41));
coefficient_plugin_electric = temperature_coefficients(boolean(Q42));
coefficient_gas = temperature_coefficients(boolean(Q43));
coefficient_oil = temperature_coefficients(boolean(Q44));
coefficient_solid = temperature_coefficients(boolean(Q45));
coefficient_renewable = temperature_coefficients(boolean(Q46));
coefficient_other = temperature_coefficients(boolean(Q47));

numbers = length(coefficient_central_electric) + ...
            length(coefficient_plugin_electric) + ...
            length(coefficient_gas) + ...
            length(coefficient_oil) + ...
            length(coefficient_solid) + ...
            length(coefficient_renewable) + ...
            length(coefficient_other);

onlyQ41 = (Q41 == 1 & (Q42+Q43+Q44+Q45+Q46+Q47) == 0);
onlyQ42 = (Q42 == 1 & (Q41+Q43+Q44+Q45+Q46+Q47) == 0);
onlyQ43 = (Q43 == 1 & (Q41+Q42+Q44+Q45+Q46+Q47) == 0);
onlyQ44 = (Q44 == 1 & (Q41+Q42+Q43+Q45+Q46+Q47) == 0);
onlyQ45 = (Q45 == 1 & (Q41+Q42+Q43+Q44+Q46+Q47) == 0);
onlyQ46 = (Q46 == 1 & (Q41+Q42+Q43+Q44+Q45+Q47) == 0);
onlyQ47 = (Q47 == 1 & (Q41+Q42+Q43+Q44+Q45+Q46) == 0);

coefficient_only_central = temperature_coefficients(boolean(onlyQ41));
coefficient_only_plugin = temperature_coefficients(boolean(onlyQ42));
coefficient_only_gas = temperature_coefficients(boolean(onlyQ43));
coefficient_only_oil = temperature_coefficients(boolean(onlyQ44));
coefficient_only_solid = temperature_coefficients(boolean(onlyQ45));
coefficient_only_renewable = temperature_coefficients(boolean(onlyQ46));
coefficient_only_other = temperature_coefficients(boolean(onlyQ47));

numbers_only = length(coefficient_only_central) + ...
            length(coefficient_only_plugin) + ...
            length(coefficient_only_gas) + ...
            length(coefficient_only_oil) + ...
            length(coefficient_only_solid) + ...
            length(coefficient_only_renewable) + ...
            length(coefficient_only_other);

numbers_only_array =  [ length(coefficient_only_central), 
            length(coefficient_only_plugin), 
            length(coefficient_only_gas), 
            length(coefficient_only_oil), 
            length(coefficient_only_solid), 
            length(coefficient_only_renewable), 
            length(coefficient_only_other)];
        
coefficients = [];
coefficients = [ coefficients, ...
                    coefficient_central_electric', ...
                    coefficient_plugin_electric', ...
                    coefficient_gas', ...
                    coefficient_oil', ...
                    coefficient_solid', ...
                    coefficient_renewable', ...
                    coefficient_other', ...
                    ];

label = [];
label = [ label, ...
                    1 * ones(1, length(coefficient_central_electric)), ...
                    2 * ones(1, length(coefficient_plugin_electric)), ...
                    3 * ones(1, length(coefficient_gas)), ...
                    4 * ones(1, length(coefficient_oil)), ...
                    5 * ones(1, length(coefficient_solid)), ...
                    6 * ones(1, length(coefficient_renewable)), ...
                    7 * ones(1, length(coefficient_other)), ...
                    ];

coefficients_only = [];
coefficients_only = [ coefficients_only, ...
                    coefficient_only_central', ...
                    coefficient_only_plugin', ...
                    coefficient_only_gas', ...
                    coefficient_only_oil', ...
                    coefficient_only_solid', ...
                    coefficient_only_renewable', ...
                    coefficient_only_other', ...
                    ];

label_only = [];
label_only = [ label_only, ...
                    1 * ones(1, length(coefficient_only_central)), ...
                    2 * ones(1, length(coefficient_only_plugin)), ...
                    3 * ones(1, length(coefficient_only_gas)), ...
                    4 * ones(1, length(coefficient_only_oil)), ...
                    5 * ones(1, length(coefficient_only_solid)), ...
                    6 * ones(1, length(coefficient_only_renewable)), ...
                    7 * ones(1, length(coefficient_only_other)), ...
                    ];

legend = {'Electr. central', 'Electr. plug in', 'Gas', 'Oil', 'Solid fuel', 'Renewable', 'Other'};

fig = figure; 
position_O = 1:7;  

box1 = boxplot(coefficients_only, label_only, 'labels', legend, 'positions', position_O, 'width', 0.18);
% ylabel('Temperature coefficient');
% set(gca, 'XTickLabelRotation', 45); 
% set(gcf, 'color', 'w');
% grid on;
% fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
% filename = 'heating_coefficient_single';
% export_fig('-cmyk', '-pdf', [folder, filename, '.pdf']);
% close(fig);
set(gca,'XTickLabel',{' '})  % Erase xlabels   
hold on;

position_1 = 1.3:1:7.3
box2 = boxplot(coefficients, label, 'labels', legend, 'positions',position_1,'width',0.18);

hold off;
ylim([-0.07,0.02]);
ylabel('Temperature coefficient');

set(gca, 'XTickLabelRotation', 45); 

set(gcf, 'color', 'w');

grid on;

fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
filename = 'heating_coefficient_new';
export_fig('-cmyk', '-pdf', [folder, filename, '.pdf']);
% csvwrite([folder, filename, '_only.csv'], coefficients_only);
% csvwrite([folder, filename, '.csv'], coefficients);
close(fig);

return;




% text('Position',[1.1,0],'String','January') 
% text('Position',[2.1,0],'String','February') 
% text('Position',[3.1,0],'String','March') 
% text('Position',[4.1,0],'String','April') 
% text('Position',[5.1,0],'String','May') 
% text('Position',[6.1,0],'String','June') 
% text('Position',[7.1,0],'String','July') 
% text('Position',[8.1,0],'String','August') 
% text('Position',[9.1,0],'String','September') 
% text('Position',[10.1,0],'String','October') 
% text('Position',[11.1,0],'String','November') 
% text('Position',[12.1,0],'String','December') 
% 
% set(gca,'XTickLabel',{''});   % To hide outliers 
% out_O = box_O(end,~isnan(box_O(end,:)));  
% delete(out_O)  
% out_S = box_S(end,~isnan(box_S(end,:)));  
% delete(out_S)



