function T = parallel( host,database,authors,varargin )
%KECS Call KECS procedure

    % validators
    islogicalchar = @(x) ischar(x) || islogical(x);
    iscellchar = @(x) ischar(x) || iscell(x);
    
    % arguments
    p = inputParser;
    p.addRequired('Host',@ischar);
    p.addRequired('Database',@ischar);
    p.addRequired('Authors',iscellchar);
    p.addParameter('After',0,@isdatetime);
    p.addParameter('Before',2147483647,@isdatetime);
    p.addParameter('OutputFile',false,islogicalchar);
    p.parse(host,database,authors,varargin{:});
    
    % build command
    function authors = iif_authors(authors)
        if ischar(authors)
            authors = authors;
        elseif iscell(authors)
            authors = sprintf('%s ',authors{:});
        end
    end
    
    cmd = sprintf('%s ',...
        'pkecs',...
        '-h',p.Results.Host,...
        '-d',p.Results.Database,...
        '-a',num2str(posixtime(p.Results.After)),...
        '-b',num2str(posixtime(p.Results.Before)),...
        '-k',...
        iif(ischar(p.Results.OutputFile),'-o',char.empty),iif(ischar(p.Results.OutputFile),p.Results.Authors,char.empty),...
        iif(ischar(p.Results.Authors),'-f',char.empty),...
        iif_authors(p.Results.Authors)...
    );
    
    % execute
    [~,output] = unix(cmd);
    
    % parse results
    [columns,pos] = textscan(output,'%s\t%s\t%s\t%s\t%s',1);
    data = textscan(output(pos+1:end),'%s\t%u\t%u\t%u\t%u');
    T = table(data{:},'VariableNames',[columns{:}]);
end

