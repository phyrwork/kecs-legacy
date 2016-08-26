function A = pad2size( A,padsize )
%PAD2SIZE Similar to pad, but instead pad array to a specific size
%instead of by an amount
    
    for n = 1:numel(padsize)
        if n == 1
            dims = padsize(n);
        else
            dims = [zeros(1,n-1),padsize(n)];
        end
        A = padarray(A,dims-size(A,n),'post');
    end
    
end

