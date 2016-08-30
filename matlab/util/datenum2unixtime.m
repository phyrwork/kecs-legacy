function unixtime = datenum2unixtime( dn )
    
    unixtime = (dn - 719529)*86400;

    %dn = unix_time/86400 + 719529;         %# == datenum(1970,1,1)
end