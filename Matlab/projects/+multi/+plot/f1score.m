input_path = 'projects/+multi/results/';
figure_path = 'projects/+multi/+plot/f1score/';

if ~exist(figure_path, 'dir')
    mkdir(figure_path);
end

load([input_path, 'br/results.mat']);
load([input_path, 'pcc2/results.mat']);
load([input_path, 'power_set/results.mat']);

combinations = multi.get_combinations();

fig = figure;
hold on;
for c = 1:length(combinations)
    
    y_br = f1score_br{c};
    y_pcc2 = f1score_pcc2{c};
    y_ps = f1score_ps{c};
    
    plot(c, y_br, 'x', 'Color', 'b');
    plot(c, y_pcc2, 'x', 'Color', 'k');
    if ~isempty(y_ps)
        plot(c, y_ps, 'x', 'Color', 'r');
    end
    
end

title('F1 scores');

set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'on');
        
legend('BR', 'PCC', 'PS', 'Location', 'SE');

xlabel('Set')
ylabel('F1 score');

ylim([0, 1.01]);
xlim([0.5, c+0.5]);

width = 10;
height = 8;
fontsize = 8;
linewidth = 1.5;
fig = make_report_ready(fig, 'size', [width height linewidth fontsize]);

saveas(fig, [figure_path, 'f1scores'], 'png');

close(fig);

