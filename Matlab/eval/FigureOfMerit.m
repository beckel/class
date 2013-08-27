% This file is part of the project CLASS (https://github.com/beckel/class).
% Licence: GPL 2.0 (http://www.gnu.org/licenses/gpl-2.0.html)
% Copyright: ETH Zurich & TU Darmstadt, 2012
% Authors: Christian Beckel (beckel@inf.ethz.ch), Leyna Sadamori (sadamori@inf.ethz.ch)

classdef FigureOfMerit
    properties
        method
        eval_function
        param
    end
    methods
        function obj = FigureOfMerit(method, eval, param)
            obj.method = method;
            obj.eval_function = eval;
            
            if nargin > 2
                obj.param = param;
            else
                obj.param = NaN;
            end
        end
        
        
        function f = evaluate(obj, sCR)
            if isnan(obj.param)
                f = obj.eval_function(sCR);
            else 
                f = obj.eval_function(sCR, obj.param);
            end
        end
        
        function text = printText(obj)
            if isnan(obj.param)
                text = obj.method;
            else
                text = [obj.method, ' (param = ', num2str(obj.param), ')'];
            end
        end

        function text = printShortText(obj)
            if isnan(obj.param)
                text = obj.method;
            else
                text = [obj.method, '_', num2str(obj.param)];
            end
        end
    end
end
