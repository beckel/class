
src_folder = 'data/cer_ireland/weekly_traces/';
dest_folder = 'data/cer_ireland/weekly_traces_transformed/';
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

