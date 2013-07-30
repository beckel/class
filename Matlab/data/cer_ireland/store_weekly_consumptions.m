clc;
close all;
clearvars;

%% (1) Obtain user ids from database whose consumption should be stored
connection = cer_db_get_connection();
select = 'ID';
from = 'UserProfile';
orderby = 'ID';
where = 'Type = 1'; % Only residents (no "SME", no "Other")
query = query_builder(select, from, where, orderby);
fprintf('%s\n', query);
curs = fetch(exec(connection, query));
ids = cell2mat(curs.data);
close(connection);

%% (2) Obtain consumption data for these user ids
dest_folder = 'data/cer_ireland/weekly_traces/';
warning off;
mkdir(dest_folder);
warning on;

avg_time = 0;
for i = 1:length(ids)
	tic;
	id = ids(i);

    connection = cer_db_get_connection();

    % get weeks
    select = 'YEARWEEK(TimeCode,3) as Week, MAX(Status) AS Stat';
    from = 'Traces';
    where = ['ID = ', int2str(id), ' AND TimeCode IS NOT NULL'];
    groupby = 'YEARWEEK(TimeCode,3)';
    orderby = 'DATE(TimeCode)';
    query = query_builder(select, from, where, orderby, groupby);
    % fprintf('%s\n', query);
    curs = fetch(exec(connection, query));
    weeks = cell2mat(curs.data(:,1));

    % get weekly load curves
    consumptions = [];
    timelines = [];
    num_weeks = length(weeks);
    for week = 1 : num_weeks
        select = 'Used, TimeCode';
        from = 'Traces';
        where = ['ID = ', int2str(id), ' AND YEARWEEK(TimeCode,3) = ', num2str(weeks(week))];
        orderby = 'TimeCode';
        query = query_builder(select, from, where, orderby);
        % fprintf('%s\n', query);
        curs = fetch(exec(connection, query));
        weekly_consumption = curs.Data(:,1);
        timeline = curs.Data(:,2);
        % discard if week is not complete
        if length(weekly_consumption) ~= 7*48
            % are only two values missing?
            % add two data points to account for time change
            if length(weekly_consumption) == 7*48-2
                weekly_consumption(295:336) = weekly_consumption(293:end);
                timeline(295:336) = timeline(293:end);
                timeline{290} = '2010-03-28 00:30:00.0';
                timeline{291} = '2010-03-28 01:00:00.0';
                timeline{292} = '2010-03-28 01:30:00.0';
                timeline{293} = '2010-03-28 02:00:00.0';
                timeline{294} = '2010-03-28 02:30:00.0';
            else
                continue;
            end
        end
         
        % store consumption and timeline
    
        consumptions = [ consumptions; weekly_consumption' ];
        timelines = [ timelines; timeline' ];
        
    end  
        
    
    % convert 'consumptions' from cell array to num array
    consumption_arrays = cellfun(@(x) str2num(x), consumptions);
    
    % for some reason, going through the timline cell array line by line
    % is much faster than using cellfun.
    % timeline_arrays = cellfun(@(x) datenum(x), timelines);
    num_weeks = size(timelines,1);
    timeline_arrays = zeros(num_weeks, 7*48);
    for week = 1 : num_weeks
        timeline_arrays(week,:) = datenum(timelines(week,:));
    end

 	fprintf('ID: %i, %i weeks extracted.\n', id, num_weeks);
 	Consumer = struct('id', id, 'timeline', timeline_arrays, 'consumption', consumption_arrays);
 	save([dest_folder, num2str(id)], 'Consumer');
 	t = toc;
 	avg_time = (avg_time * (i-1) + t * 1) / i;
 	eta = avg_time * (length(ids) - i);
 	fprintf('Progress: %i%% (%i of %i). ETA: %s\n', round(i*100/length(ids)), i, length(ids), seconds2str(eta));
    
    clear consumption_arrays;
    clear consumptions;
    clear timeline;
    clear timeline_arrays;
    clear timelines;
    clear weekly_consumption;
    clear weeks;

    close(connection);
end
 

