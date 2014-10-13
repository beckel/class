function [ averages ] = cer_get_consumption_averages(households)

    num_households = length(households);
    averages = zeros(1, num_households);
    for h = 1:num_households
        household = households(h);
        filename = ['data/cer_ireland/weekly_traces/', num2str(household), '.mat'];
        load(filename);
        cons = Consumer.consumption(Consumer.consumption > 0);
        averages(h) = mean(cons);
        clear Consumer.consumption;
    end

end
