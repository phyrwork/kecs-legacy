function N = abslog10( n )
%ABSLOG10 Get log10(abs(n)) * sign(n)

    N = log10(abs(n));
    N(n < 0) = -N(n < 0);
    N(n == 0) = 0;
end

