
%% INIT
clear all;
result_path = 'projects/+diss/results/regression/';
figure_path = '/Users/beckel/Documents/SVN/mine/Thesis/document/figures/05_applications/household_classification/regression/';
if ~exist(figure_path, 'dir')
    mkdir(figure_path);
end
width = 8;
height = 8;
fontsize = 8;
file = 'peer_group_comparison';

%% Calculation
cer_ids;

connection = cer_db_get_connection();
select = 'UserProfile.id, Floorsize_updated, Devices, Persons';
from = 'PreTrial_Answers INNER JOIN UserProfile ON PreTrial_Answers.ID = UserProfile.ID';
orderby = 'UserProfile.id';
query = query_builder(select, from, orderby);
fprintf('%s\n', query);
curs = fetch(exec(connection, query));

ids = cell2mat(curs.data(:,1));
floorsize = cell2mat(curs.data(:,2));
devices = cell2mat(curs.data(:,3));
persons = cell2mat(curs.data(:,4));

ids_valid = ids(~isnan(floorsize) & ~isnan(devices) & ~isnan(persons));

[ids, idx, ~] = intersect(ids, intersect(ids_valid, setdiff(union(type1, type3), exclude)));
floorsize = floorsize(idx);
devices = devices(idx);
persons = persons(idx);

close(connection);

% get average consumption
load('avg_cons_all_users.mat');
idx = ismember(household_ids, ids);
consumption = avg_cons_all_users(idx);

% get regression coefficients

X = [];
X = [ X, floorsize, devices, persons];
X = [ X, ones(length(ids), 1) ];
    
y = consumption';

% b: coefficient estimates
% bint: 95% estimates of the coefficient estimates
% r: residuals
% rint: outlier detection
% http://www.mathworks.ch/ch/help/stats/regress.html
% [b1,bint1,r1,rint1,stats1] = regress(training_truth, sC.training_set');
[b,bint,r,rint,stats] = regress(y, X);
    
coef_floorsize = b(1);
coef_devices = b(2);
coef_persons = b(3);
coef_const = b(4); 

consumption_computed_questionnaires = floorsize .* b(1) + devices .* b(2) + persons .* b(3) + b(4);
consumption_actual = consumption;


% now get consumption that is computed from the quetionnaire estimates
num_weeks = 75;
prediction_floorarea = zeros(num_weeks, length(ids));
truth_floorarea = zeros(num_weeks, length(ids));
prediction_persons = zeros(num_weeks, length(ids));
truth_persons = zeros(num_weeks, length(ids));
prediction_devices = zeros(num_weeks, length(ids));
truth_devices = zeros(num_weeks, length(ids));
for week = 1:num_weeks
    % floor size
    filename = [result_path, num2str(week), '/sffs/sR-Floorarea_rsquare_adjusted_linear.mat'];
    load(filename);
   
    households = [ sR{1}.households, sR{2}.households, sR{3}.households, sR{4}.households ];
    prediction = [ sR{1}.prediction, sR{2}.prediction, sR{3}.prediction, sR{4}.prediction ];
    truth = [ sR{1}.truth, sR{2}.truth, sR{3}.truth, sR{4}.truth ];
    
    for i = 1:length(ids)
        id = ids(i);
        idx = find(households==id);
        if idx ~= 0
            prediction_floorarea(week, i) = prediction(idx);
            truth_floorarea(week, i) = truth(idx);
        end
    end
    
    % persons
    filename = [result_path, num2str(week), '/sffs/sR-Persons_rsquare_adjusted_linear.mat'];
    load(filename);
   
    households = [ sR{1}.households, sR{2}.households, sR{3}.households, sR{4}.households ];
    prediction = [ sR{1}.prediction, sR{2}.prediction, sR{3}.prediction, sR{4}.prediction ];
    truth = [ sR{1}.truth, sR{2}.truth, sR{3}.truth, sR{4}.truth ];
    
    for i = 1:length(ids)
        id = ids(i);
        idx = find(households==id);
        if idx ~= 0
            prediction_persons(week, i) = prediction(idx);
            truth_persons(week, i) = truth(idx);
        end
    end
    
    % floor size
    filename = [result_path, num2str(week), '/sffs/sR-Devices_rsquare_adjusted_linear.mat'];
    load(filename);
   
    households = [ sR{1}.households, sR{2}.households, sR{3}.households, sR{4}.households ];
    prediction = [ sR{1}.prediction, sR{2}.prediction, sR{3}.prediction, sR{4}.prediction ];
    truth = [ sR{1}.truth, sR{2}.truth, sR{3}.truth, sR{4}.truth ];
    
    for i = 1:length(ids)
        id = ids(i);
        idx = find(households==id);
        if idx ~= 0
            prediction_devices(week, i) = prediction(idx);
            truth_devices(week, i) = truth(idx);
        end
    end
end

pred_floorarea = zeros(length(ids), 1);
pred_persons = zeros(length(ids), 1);
pred_devices = zeros(length(ids), 1);

for i = 1:length(ids)
    tmp = prediction_floorarea(:, i);
    pred_floorarea(i) = mean(tmp(tmp>0));
    tmp = prediction_persons(:, i);
    pred_persons(i) = mean(tmp(tmp>0));
    tmp = prediction_devices(:, i);
    pred_devices(i) = mean(tmp(tmp>0));
    
end    

consumption_computed_estimation = pred_floorarea .* b(1) + pred_devices .* b(2) + pred_persons .* b(3) + b(4); 
consumption_computed_questionnaires;
consumption_actual = consumption;

%%

fig = figure;
plot(consumption_actual, consumption_computed_questionnaires, 'x');
xlim([0, 1.5]);
ylim([0, 1.5]);
xlabel('Consumption norm (computed) [W]');
ylabel('Calculated consumption [W]');
fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);    
export_fig('-cmyk', '-pdf', [figure_path, file, '_questionnaire', '.pdf']);
close(fig);

% fig = figure;
% hold on;
% plot(consumption_actual, consumption_computed_questionnaires, 'x', 'Color', 'b');
% plot(consumption_actual, consumption_computed_estimation, 'x');
% for i = 1:length(ids)
%     line([consumption_actual(i), consumption_actual(i)], [consumption_computed_questionnaires(i), consumption_computed_estimation(i)], 'Color', 'r');
% end
% xlim([0, 1.5]);
% ylim([0, 1.5]);
% xlabel('Consumption norm (computed and estimated) [W]');
% ylabel('Calculated consumption [W]');
% fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);    
% export_fig('-cmyk', '-pdf', [figure_path, file, '_estimation', '.pdf']);
% close(fig);
% 

fig = figure;
hold on;
% plot(consumption_actual, consumption_computed_questionnaires, 'x', 'Color', 'b');
plot(consumption_actual, consumption_computed_estimation, 'x', 'Color', [1 .5 0]);
% for i = 1:length(ids)
%     line([consumption_actual(i), consumption_actual(i)], [consumption_computed_questionnaires(i), consumption_computed_estimation(i)], 'Color', 'r');
% end
xlim([0, 1.5]);
ylim([0, 1.5]);
xlabel('Consumption norm (computed and estimated) [W]');
ylabel('Calculated consumption [W]');
fig = make_report_ready(fig, 'size', [width, height], 'fontsize', fontsize);    
export_fig('-cmyk', '-pdf', [figure_path, file, '_estimation', '.pdf']);
close(fig);

