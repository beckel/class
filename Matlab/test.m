%     distances = sCR{1}.distance;
%     distances = sortrows(distances, 1);
%     num_class1 = sum(distances(:,1) == 1);
%     distances(1:num_class1,:) = sortrows(distances(1:num_class1,:), -2);
%     % del next row
%     distances(num_class1+1:end,2) = -1 * distances(num_class1+1:end,2);
%     distances(num_class1+1:end,:) = sortrows(distances(num_class1+1:end,:), -2);
%     samples = distances(:,2);
%     truth = distances(:,3);
% 
%     [X,Y,T,AUC] = perfcurve(truth, samples, 1)
%     
%     plot(X,Y)

src_folder = 'data/cer_ireland/weekly_traces/new/';
dest_folder = 'data/cer_ireland/weekly_traces_new/';
if ~exist(dest_folder, 'dir')
    mkdir(dest_folder);
end

D = dir(src_folder);
D(1:2) = [];
for i = 1:length(D)
    filename = D(i).name;
    load([src_folder, filename]);
    
    % weeks that are present
    new_consumption = zeros(75,336);
    num_available_weeks = size(Consumer.timeline, 1);
    for j = 1:num_available_weeks
        new_idx = ((Consumer.timeline(j) - 733974) / 7) + 1;
        new_consumption(new_idx,:) = Consumer.consumption(j,:);
    end
    
    NewConsumer.id = Consumer.id;
    NewConsumer.consumption = new_consumption;
    Consumer = NewConsumer;
    
    save([dest_folder, filename], 'Consumer');

end

