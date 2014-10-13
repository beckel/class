% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

classdef Logbook < handle
    properties
        entries
        num_entries
    end
    
    methods
        function obj = Logbook(num_entries)
            obj.num_entries = num_entries;
            obj.entries = {};
        end
        
        function add(obj, array)
            if length(array) > obj.num_entries
                error('Only %d entries allowed in logbook\n');
            end

%             if obj.contains(array) == 1
%                 error('Array already in logbook\n');
%                 return;
%             else
                tmp = sort(array);
                obj.entries{end+1} = [ tmp, zeros(1, obj.num_entries - length(array)) ];
%             end
        end
        
        function ret = contains(obj, array)
            tmp = sort(array);
            array_padded = [ tmp, zeros(1, obj.num_entries - length(array)) ];
            for i = 1:length(obj.entries)
                if array_padded == obj.entries{i}
                    ret = 1;
                    return;
                end
            end
            ret = 0;
        end
    end
end
