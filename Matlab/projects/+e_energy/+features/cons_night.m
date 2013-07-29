% average consumption during night (01am - 5am)
function feature = cons_night(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 3;
            stop = (i-1) * 48 + 10;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
            
            if (feature(i) > 1)
                feature(i) = 1;
            end
            
            feature(i) = sqrt(feature(i));
            
        end
    end
end 
   