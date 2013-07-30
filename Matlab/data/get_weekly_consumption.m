function Consumer = get_weekly_consumption(id, dataset)
	Consumer = [];
    if strcmp(dataset, 'cer_ireland') == 1
        load(['data/cer_ireland/weekly_traces2/', num2str(id)]);
    end
end