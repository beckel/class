% Copyright: ETH Zurich, 07/2012
% Institute for Pervasive Computing
% Distributed Systems Group
% Christian Beckel (beckel@inf.ethz.ch)

% "cross correlation between weekdays (average from mo/tue, tue/wed, wed/thur, thur/fri)
% (no shift in signal to account for changing schedules)
% http://www.icbm.de/studproj/kp_helgoland_05/tsa_korrelation.html"
function feature = cross_correlation(consumption)
    
    if (strcmp(consumption, 'dim'))
		feature = 4;
	else
		feature = zeros(4,1);
        for i=1:4

            startX = (i-1) * 48 + 1;
            stopX = (i-1) * 48 + 48;
            startY = i * 48 + 1;
            stopY = i * 48 + 48;
        
            CorrelationCoefficient = corrcoef(consumption(startX:stopX), consumption(startY:stopY));
            feature(i) = CorrelationCoefficient(2,1);
        end
    end
end 
   