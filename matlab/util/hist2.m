function [H,Xi,Yi] = hist2(X,Y,xbins,ybins)
%HIST2

    %# bin centers
    xNumBins = numel(xbins); yNumBins = numel(ybins);

    %# map X/Y values to bin indices
    Xi = round( interp1(xbins, 1:xNumBins, X, 'linear', 'extrap') );
    Yi = round( interp1(ybins, 1:yNumBins, Y, 'linear', 'extrap') );

    %# limit indices to the range [1,numBins]
    Xi = max( min(Xi,xNumBins), 1);
    Yi = max( min(Yi,yNumBins), 1);

    %# count number of elements in each bin
    H = accumarray([Yi(:) Xi(:)], 1, [yNumBins xNumBins]);
end

