% noon consumption (cons_noon) / evening consumption (cons_evening) on weekdays
function feature = ratio_evening_noon_weekday(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 5;
	else
		feature = zeros(5,1);
        for i=1:5
            
            startNoon = (i-1) * 48 + 21;
            stopNoon = (i-1) * 48 + 28;
            noon = mean(consumption(startNoon:stopNoon));
            
            startEvening = (i-1) * 48 + 37;
            stopEvening = (i-1) * 48 + 44;
            evening = mean(consumption(startEvening:stopEvening));

            feature(i) = log(evening / noon);
            
            if feature(i) < -5
                feature(i) = -5;
            end
            
            if feature(i) > 5
                feature(i) = 5;
            end
        end
    end
end 

