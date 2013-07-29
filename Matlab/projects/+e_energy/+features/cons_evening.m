% average consumption during evenings (6pm-10pm)
function feature = cons_evening(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            start = (i-1) * 48 + 37;
            stop = (i-1) * 48 + 44;
            indices = start : stop;
            feature(i) = mean(consumption(indices));
            
            if (feature(i) > 2.5)
                feature(i) = 2.5;
            end
            
            feature(i) = sqrt(feature(i));
        end
    end
end 
   