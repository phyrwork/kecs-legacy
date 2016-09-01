function [ path ] = addpath( dir )
%ADDpath Add directory to unix path

    path = getenv('PATH');
    setenv('PATH', [path ':' dir]);
    
    path = getenv('PATH');
end

