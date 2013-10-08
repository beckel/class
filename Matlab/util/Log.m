% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

classdef Log < handle
    properties
        log_file
        log_type
        log_level
    end
    
    methods
        function obj = Log(file, log_level)
            if strcmp(file, 'console') == 1
                obj.log_type = 'console';
            else
                obj.log_type = 'file';
                obj.log_file = file;
            end
            obj.log_level = log_level;
        end
        
        function normal(obj, msg, varargin)
            if strcmp(obj.log_level, 'normal') == 1 || ...
               strcmp(obj.log_level, 'debug') == 1
                if strcmp(obj.log_type, 'console') == 1
                    fprintf(msg, varargin{:});
                else
                    fid = fopen(obj.log_file, 'a');
                    fprintf(fid, msg, varargin{:});
                    fclose(fid);
                end
            end
        end
        
        function debug(obj, msg, varargin)
            if strcmp(obj.log_level, 'debug') == 1
                if strcmp(obj.log_type, 'console') == 1
                    fprintf(msg, varargin{:});
                else
                    fid = fopen(obj.log_file, 'a');
                    fprintf(fid, msg, varargin{:});
                    fclose(fid);
                end
            end
        end
        
        function error(obj, msg, varargin)
            if strcmp(obj.log_level, 'debug') == 1
                if strcmp(obj.log_type, 'console') == 1
                    fprintf('ERROR: ');
                    fprintf(msg, varargin{:});
                    exit;
                else
                    fid = fopen(obj.log_file, 'a');
                    fprintf(fid, 'ERROR: ');
                    fprintf(fid, msg, varargin{:});
                    fclose(fid);
                    exit;
                end
            end
        end
        
        function setLogfile(obj, file)
            obj.debug('Now logging into %s\n', file);
            if strcmp(file, 'console') == 1
                obj.log_type = 'console';
            else
                obj.log_type = 'file';
                obj.log_file = file;
            end
            
            % clean log file
            fid = fopen(file, 'w');
            fclose(fid);
        end
        
        function write_comma_separated_list(obj, list)
            if strcmp(obj.log_level, 'debug') == 1
                for i=1:length(list)-1
                    obj.debug('%d, ', list(i));
                end
                obj.debug('%d', list(end));
            end
        end       
    end
end
