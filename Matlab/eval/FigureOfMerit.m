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
