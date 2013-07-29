function str = seconds2str(s)
	ms = round(rem(s, 1) * 1e4) / 10;
	
    secs = mod(s,60);
    secs = round(secs);
    m = floor(s/60);
    
    mins = mod(m,60);
    h = floor(m/60);
    
    hours = mod(h,24);
    days = floor(h/24);
	
	str = [num2str(ms), 'ms'];
	if (secs > 0)
		str = [num2str(secs), 's ', str];
	end
	if (mins > 0)
		str = [num2str(mins), 'm ', str];
	end
	if (hours > 0)
		str = [num2str(hours), 'h ', str];
	end
	if (days > 0)
		str = [num2str(days), 'd ', str];
	end
end