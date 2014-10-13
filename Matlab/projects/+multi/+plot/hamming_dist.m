input_path = 'projects/+multi/results/';
figure_path = 'projects/+multi/+plot/hamming/';

if ~exist(figure_path, 'dir')
    mkdir(figure_path);
end

load([input_path, 'br/results.mat']);
load([input_path, 'pcc2/results.mat']);
load([input_path, 'power_set/results.mat']);

combinations = multi.get_combinations();

for c = 1:length(combinations)
    
    fig = figure;
    hold on;
    
    y_br = sort(hamming_br{c});
    y_pcc2 = sort(hamming_pcc2{c});
    y_ps = sort(hamming_ps{c});
    
    plot(y_br, 'Color', 'b');
    plot(y_pcc2, 'Color', 'k');
    plot(y_ps, 'Color', 'r');
    
    title(['Hamming distance - Set ', num2str(c)]);

    legend('BR', 'PCC', 'PS', 'Location', 'SE');

    xlabel('Households')
    ylabel('Hamming distance');
    
    ylim([0, 1.01]);
    saveas(fig, [figure_path, 'set_', num2str(c)], 'png');
    
    close(fig);
end


