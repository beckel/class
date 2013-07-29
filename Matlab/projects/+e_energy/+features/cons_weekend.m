% average consumption week-end (Sa 0 am - Su 12 pm)
function feature = cons_evening(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 2;
	else
		feature = zeros(2,1);
        for i=1:2
            start = (5+i-1) * 48 + 1;
            stop = (5+i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
            
            if (feature(i) > 1.5)
                feature(i) = 1.5;
            end
        end
    end
end 
   