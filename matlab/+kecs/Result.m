classdef Result < handle
    %RESULT Wrapper for KECS result set - provide useful methods for
    %data analysis/visualization purposes
    
    properties
        data; % table
        struct('start',datetime.empty,'finish',datetime.empty);
    end
    
    methods
        function obj = Result(data,varargin)
            
            switch class(data)
                case 'table'
                    % use table
                    T = data;
                    
                case 'char'
                    % load file
                    ds = datastore(path,'ReadVariableNames',true'); % file to datastore
                    ds.SelectedFormats = cellfun(@(x)strrep(x,'%f','%u'),ds.SelectedFormats,'UniformOutput',false); % input data as integers
                    T = ds.readall;
                    
                otherwise
                    error('Data not supported. Supported data types: file path, table)');
            end
            
            % attach to object
            obj.data = T;
            
            % initialize times if present
            if nargin > 2
                obj.time.start = varargin{1};
            end
            if nargin > 3
                obj.time.finish = varargin{2};
            end
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

