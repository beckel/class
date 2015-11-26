% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

clearvars;

folder = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/03_household_classification/images/weather/';
if exist(folder, 'dir') == 0
    mkdir(folder);
end

% cer_ids;
% ids = setdiff(union(type1, type3), exclude);

% plotting
width = 7.7;
height = 6;
fontsize = 9;

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

%% Heating characteristics
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

legend = {'Electric (central)', 'Electric (plug-in)', 'Gas', 'Oil', 'Solid fuel', 'Renewable', 'Other'};

fig = figure;                
boxplot(coefficients_only, label_only, 'labels', legend);
ylim([-0.07,0.02]);
% title('Only single heat source');
ylabel('Heating coefficient');
set(gca, 'XTickLabelRotation', 45); 
set(gcf, 'color', 'w');
grid on;
fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
filename = 'heating_coefficient_single';
% print('-dpdf', '-cmyk', '-r600', [folder, filename, '.pdf']);
export_fig('-cmyk', '-pdf', [folder, filename, '.pdf']);
close(fig);

fig = figure;                
boxplot(coefficients, label, 'labels', legend);
ylim([-0.07,0.02]);
% title('Including multiple heat sources');
ylabel('Heating coefficient');
set(gca, 'XTickLabelRotation', 45); 
set(gcf, 'color', 'w');
grid on;
fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);
filename = 'heating_coefficient_overlap';
% print('-dpdf', '-cmyk', '-r600', [folder, filename, '.pdf']);
export_fig('-cmyk', '-pdf', [folder, filename, '.pdf']);
close(fig);

