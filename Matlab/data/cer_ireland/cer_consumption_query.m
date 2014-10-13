function [ ret ] = cer_consumption_query(type, id)

if strcmp(type, 'avg') == 1
    filename = ['data/cer_ireland/weekly_traces/', num2str(id), '.mat'];
    load(filename);
    cons = Consumer.consumption(Consumer.consumption > 0);
    ret = mean(cons);
    clear Consumer.consumption;

end


