% morning consumption (cons_morning) / noon consumption (cons_noon) on weekdays
function feature = ratio_morning_noon_weekday(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 5;
	else
		feature = zeros(5,1);
        for i=1:5
            
            startMorning = (i-1) * 48 + 13;
            stopMorning = (i-1) * 48 + 20;
            morning = mean(consumption(startMorning:stopMorning));
            
            startNoon = (i-1) * 48 + 21;
            stopNoon = (i-1) * 48 + 28;
            noon = mean(consumption(startNoon:stopNoon));
            
            feature(i) = log((morning / noon));
            
            if feature(i) < -5
                feature(i) = -5;
            end
            
            if feature(i) > 5
                feature(i) = 5;
            end

%             if isnan(feature(i))
%                 feature(i) = 1;
%             end
        end
    end
end 

