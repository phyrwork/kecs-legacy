classdef Result < handle
    %RESULT Wrapper for KECS result set - provide useful methods for
    %data analysis/visualization purposes
    
    properties
        data; % table
        time_start;
        time_end;
    end
    
    methods
        function obj = Result(path)
            % import data
            ds = datastore(path,'ReadVariableNames',true'); % file to datastore
            ds.SelectedFormats = cellfun(@(x)strrep(x,'%f','%u'),ds.SelectedFormats,'UniformOutput',false); % input data as integers
            obj.data = ds.readall;
        end
        
        function len = length(obj)
            len = height(obj.data);
        end
        
        function data = get(obj,field,varargin)
            if nargin < 3
                rows = 1:obj.length;
            else
                rows = varargin{1};
            end
            
            data = obj.data.(field);
            data = data(rows);
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
            
            obj.data = sortrows(obj.data,field,dir);
        end
        
        function loc = find(obj,field,value)
            
            if ischar(value)
                loc = find(strcmp(obj.data.(field),value));
            else
                loc = find(obj.data.(field) == value);
            end
        end
        
    end
    
end

