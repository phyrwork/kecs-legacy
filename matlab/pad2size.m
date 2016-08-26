function A = pad2size( A,padsize )
%PAD2SIZE Similar to pad, but instead pad array to a specific size
%instead of by an amount

    dims = size(A);
    
    for n = 1:numel(padsize)
        A = padarray(A,[zeros(1,n-1),padsize(n)],'post');
    end
    
end

