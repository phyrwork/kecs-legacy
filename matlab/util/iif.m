function result = iif( condition,valiftrue,valiffalse )
%IIF Test condition; output valiftrue when true, valiffalse when false
    
    if condition
        result = valiftrue;
    else
        result = valiffalse;
    end
end

