% average consumption during mornings (06-10am)
function feature = cons_morning(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 13;
            stop = (i-1) * 48 + 20;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
            
            if (feature(i) > 1.5)
                feature(i) = 1.5;
            end
            
            feature(i) = sqrt(feature(i));
        end
    end
end 
   