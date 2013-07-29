% consumption_variability - Sum(|P(t)-P(t-1)|) for all t throughout a day
function feature = consumption_variability(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            
            start = (i-1) * 48 + 2;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            
            feature(i) = sum(abs(consumption(indices) - consumption(indices-1)));
            
            if (feature(i) > 30)
                feature(i) = 30;
            end
        end
    end
end 
   