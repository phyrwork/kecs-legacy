function unixtime = ymd2unixtime( y,m,d )
    
    if nargin < 3
        d = 1;
    end
    if nargin < 2
        m = 1;
    end
    
    dn = datenum(datetime(y,m,d));

    unixtime = (dn - 719529)*86400;
    unixtime = uint64(unixtime);
end