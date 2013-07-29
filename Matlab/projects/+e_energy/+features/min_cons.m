% daily minimum
function feature = min_cons(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 1;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = min(consumption(indices));
            
            
            if feature(i) > 0.5
                feature(i) = 0.5;
            end
            
            feature(i) = sqrt(feature(i));
        end
    end
end 