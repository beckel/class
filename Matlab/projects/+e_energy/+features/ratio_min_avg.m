% minimum consumption / average consumption
function feature = ratio_min_avg(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 1;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = min(consumption(indices)) / mean(consumption(indices));

            % 0/0
%             if isnan(feature(i))
%                  feature(i) = 1;
%             end
            
            feature(i) = sqrt(feature(i));
        end
                
    end
end 