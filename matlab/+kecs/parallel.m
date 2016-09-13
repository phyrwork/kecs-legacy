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
    p.addParameter('DescendantsAfter',datetime.empty,@isdatetime);
    p.addParameter('After',datetime(2000,01,01),@isdatetime);
    p.addParameter('Before',datetime(2030,01,01),@isdatetime);
    p.addParameter('OutputFile',false,islogicalchar);
    p.addParameter('Cpu',8,@isnumeric);
    p.parse(host,database,authors,varargin{:});
    
    % defaults
    desc_after = p.Results.DescendantsAfter;
    if isempty(desc_after)
        desc_after = p.Results.After - calmonths(6) - caldays(1);
    end
    
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
        '-j',num2str(p.Results.Cpu),...
        '-s',num2str(posixtime(desc_after)),...
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
    try
        [columns,pos] = textscan(output,'%s\t%s\t%s\t%s\t%s',1);
        data = textscan(output(pos+1:end),'%s\t%u\t%u\t%u\t%u');
        T = table(data{:},'VariableNames',[columns{:}]);
    catch
        error(output);
    end
end

