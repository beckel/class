% daily maximum
function feature = max_cons(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 1;
            stop = (i-1) * 48 + 48;
            indices = start : stop;
            feature(i) = max(consumption(indices));
            
            if (feature(i) > 6)
                feature(i) = 6;
            end
        end
    end
end 