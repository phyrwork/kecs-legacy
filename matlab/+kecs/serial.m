function T = serial( host,database,author,search_after,time_start,time_end )
%KECS Call KECS procedure

    % defaults
    if nargin < 4
        search_after = 0;
    end
    
    if nargin < 5
        time_start = 0;
    end
    
    if nargin < 6
        time_end = 2147483647;
    end
    
    % build command
    cmd = sprintf('%s ',...
        'kecs',...
        '-h',host,...
        '-d',database,...
        '-s',num2str(search_after),...
        '-a',num2str(time_start),...
        '-b',num2str(time_end),...
        '-k',...
        author...
    );
    
    % execute
    [~,output] = unix(cmd);
    
    % parse results
    [columns,pos] = textscan(output,'%s\t%s\t%s\t%s\t%s',1);
    data = textscan(output(pos+1:end),'%s\t%u\t%u\t%u\t%u');
    T = table(data{:},'VariableNames',[columns{:}]);
end

