function plot(R,NumXBins,NumYBins)

    Score = abslog10(double(R.get('score'))); % score in log10
    ScoreSelf = abslog10(double(R.get('score_self')));

    N = numel(Score);

    % Calculate X bins
    XBinWidth = N/NumXBins; % bin width
    XBin = 1:XBinWidth:XBinWidth*ceil(N/XBinWidth); % top bin extends past the end of the dataset

    % Calculate Y bins
    YBinMin = min(Score);
    YBinMax = max(Score);
    YBinWidth = (YBinMax-YBinMin)/NumYBins;
    YBin = YBinMin:YBinWidth:YBinWidth*ceil(YBinMax/YBinWidth);
                    % Y is log10(score)

    % Bin data points by 
    [H,Xi,Yi] = hist2(1:N,Score,XBin,YBin);
    H = log10(H+1);   % H + 1 to move 0s to 1
                    % ln H to compress range
                    % H represents ln(count)

    % Configure colors
    figure; 
    colormap('parula'); % set colormap
    C = colormap; % get colors
    Cn = size(C,1);

    % Bin data point colours
    HMax = max(H(:));
    HMin = min(H(:));
    HDiv = HMax/Cn; % ln(count)/bin
    Yc = ceil(interp2(H,Xi',Yi)/(HDiv)); % bins H into Yc = 1:64 range
        % 1:Cn = ln(H)/(HDiv)
        % ln(Htop) = Cn*HDiv

    % Plot
    scatter(1:N,Score,1,C(Yc,:),'.');
    
    hold on
    plot(1:N,ScoreSelf,'r','LineWidth',1.5);
    
    % Label
    Cb = colorbar;
    Cb.Label.String = 'Users per bin';
    set(gca, 'CLim', [0, 64]);
    L = [0,10.^(1:floor(HMax))]; % tick marks - powers of 10 up to below max
    l = ceil(log10(L+1)/HDiv); % tick index
    set(Cb,'YTick',l,'YTicklabel',L);
    
    ylabel('Karma');
    Lm = -10.^-(ceil(YBinMin):-1);
    Lp = 10.^(1:floor(YBinMax));
    L = [Lm,0,Lp];
    l = abslog10(L);
    set(gca,'YTick',l,'YTickLabel',L);
    ylim([min([Score;ScoreSelf])-0.25,max([Score;ScoreSelf])+0.25]);
    
    xlabel('User rank (by self karma)');
    l = 0:1000000:N;
    l = [1,l(2:end)];
    %L = arrayfun(@num2str,l,'UniformOutput',false);
    L = l;
    set(gca,'XTick',l,'XTickLabel',L,'XTickLabelRotation',45);
    xlim([1,N]);
    
    legend({'Total descendant karma','Self karma'})
    
    title('User contribution to reddit in terms of total descendant post karma in 2015');
end