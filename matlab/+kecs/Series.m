classdef Series < handle
    %RESULTSERIES
    
    properties
        result@kecs.Result vector;
    end
    
    methods
        function obj = Series(result)
            if size(result,1) > size(result,2)
                obj.result = result';
            else
                obj.result = result;
            end
                
        end
        
        function len = length(obj)
            len = numel(obj.result);
        end
        
        function data = get(obj,field)
            
            data = cell.empty;
            for r = obj.result
                data{end+1} = pad2size(r.get(field),max(arrayfun(@length,obj.result)));
            end
            
            data = horzcat(data{:});
        end
        
        function obj = sort(obj,varargin)
            
            if nargin < 2
                field = 'score';
            else
                field = varargin{1};
            end
            
            if nargin < 3
                dir = 'descend';
            else
                dir = varargin{2};
            end
            
            % sort all 
            for r = obj.result
                r.sort(field,dir);
            end
        end
    end
end

