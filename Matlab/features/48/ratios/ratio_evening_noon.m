% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% noon consumption (cons_noon) / evening consumption (cons_evening) on weekdays
function feature = ratio_evening_noon(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            
            startNoon = (i-1) * 48 + 21;
            stopNoon = (i-1) * 48 + 28;
            noon = mean(consumption(startNoon:stopNoon));
            
            startEvening = (i-1) * 48 + 37;
            stopEvening = (i-1) * 48 + 44;
            evening = mean(consumption(startEvening:stopEvening));

%            feature(i) = log(evening / noon);
            feature(i) = evening / noon;
            
        end
    end
end 

