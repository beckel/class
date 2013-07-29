% night consumption / day consumption (night: 01am-05am, day: 6am-10pm)
function feature = ratio_night_day(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            
            startNight = (i-1) * 48 + 3;
            stopNight = (i-1) * 48 + 10;
            night = mean(consumption(startNight:stopNight));
            
            startDay = (i-1) * 48 + 13;
            stopDay = (i-1) * 48 + 44;
            day = mean(consumption(startDay:stopDay));
            
            feature(i) = (night / day);
            if feature(i) > 3
                feature(i) = 3;
            end
            
%             if isnan(feature(i))
%                 feature(i) = 1;
%             end
            
            feature(i) = sqrt(feature(i));
       
        end
    end
end 