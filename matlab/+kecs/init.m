function init
%STARTUP KECS initialization

    [s,~] = unix('kecs -v');
    if s ~= 0
        
        disp('KECS not found. Adding to MATLAB path...');
        addpath('/usr/local/bin');
        
        [s,~] = unix('kecs -v');
        if s ~= 0
            warning('Unable to add KECS to MATLAB path.');
            return;
        end
        
    end
    disp('KECS is installed!');
end

