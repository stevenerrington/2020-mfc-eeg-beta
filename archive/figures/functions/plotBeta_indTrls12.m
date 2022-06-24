function plotBeta_indTrls_12(inputTrls, freqs, ssrt, morletLFP, FigureLabel)

if length(inputTrls) > 12
    nTrls = 12;
else
    nTrls = length(inputTrls);
end

subplotDimension = [6, 2];
figure('Renderer', 'painters', 'Position', [100 100 600 800],'Name',FigureLabel);
colorRange = [prctile(morletLFP(:),1.5), prctile(morletLFP(:),98.5)];

for trlIdx = 1:nTrls
    trl = inputTrls(trlIdx);
    time = [-1000:1999];
    
    clear trlMorlet
    
    for freqIdx = 1:size(morletLFP,3)
        
        trlMorlet(freqIdx,:) = morletLFP(trl,:,freqIdx);
        
    end
    
    subplot(subplotDimension(1),subplotDimension(2),trlIdx)
    imagesc('XData',time,'YData',freqs,'CData',trlMorlet)
    caxis([colorRange(1) colorRange(2)])
    xlim([-250 500]); ylim([freqs(1), freqs(end)]);
    set(gca,'YDir','normal');
    vline(0,'r-'); vline(ssrt, 'r--');
    xlabel('Time from SSD (ms)'); ylabel('Frequency (Hz)')
    
end

