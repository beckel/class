function str_new = escape_char(str_old, char)
	str_new = strrep(str_old, char, ['\',char]);
end