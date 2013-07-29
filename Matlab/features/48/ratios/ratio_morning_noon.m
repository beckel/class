% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% morning consumption (cons_morning) / noon consumption (cons_noon) on weekdays
function feature = ratio_morning_noon(consumption)
    if (strcmp(consumption, 'dim'))
		feature = 7;
	else
		feature = zeros(7,1);
        for i=1:7
            
            startMorning = (i-1) * 48 + 13;
            stopMorning = (i-1) * 48 + 20;
            morning = mean(consumption(startMorning:stopMorning));
            
            startNoon = (i-1) * 48 + 21;
            stopNoon = (i-1) * 48 + 28;
            noon = mean(consumption(startNoon:stopNoon));
            
            % feature(i) = log((morning / noon));
            feature(i) = morning / noon;
            
        end
    end
end 

