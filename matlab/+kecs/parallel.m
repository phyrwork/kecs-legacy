function T = serial( host,database,authors,time_start,time_end )
%KECS Call KECS procedure

    % defaults
    if nargin < 4
        time_start = 0;
    end
    
    if nargin < 5
        time_end = 2147483647;
    end
    
    % build command
    cmd = sprintf('%s ',...
        'pkecs',...
        '-h',host,...
        '-d',database,...
        '-a',num2str(time_start),...
        '-b',num2str(time_end),...
        '-k',...
        sprintf('%s ',authors{:})...
    );
    
    % execute
    [~,output] = unix(cmd);
    
    % parse results
    [columns,pos] = textscan(output,'%s\t%s\t%s\t%s\t%s',1);
    data = textscan(output(pos+1:end),'%s\t%u\t%u\t%u\t%u');
    T = table(data{:},'VariableNames',[columns{:}]);
end

