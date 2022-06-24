function plotBeta_indTrls(inputTrls, freqs, ssrt, morletLFP, FigureLabel)

if length(inputTrls) > 60
    nTrls = 60;
else
    nTrls = length(inputTrls);
end

subplotDimension = [6, 10];
figure('Renderer', 'painters', 'Position', [100 100 1500 800],'Name',FigureLabel);

for trlIdx = 1:nTrls
    trl = inputTrls(trlIdx);
    time = [-1000:1999];
    
    clear trlMorlet
    
    for freqIdx = 1:size(morletLFP,3)
        
        trlMorlet(freqIdx,:) = morletLFP(trl,:,freqIdx);
        
    end
    
    subplot(subplotDimension(1),subplotDimension(2),trlIdx)
    imagesc('XData',time,'YData',freqs,'CData',trlMorlet)
    xlim([-250 500]); ylim([freqs(1), freqs(end)]);
    set(gca,'YDir','normal');
    vline(0,'r-'); vline(ssrt, 'r--');
    xlabel('Time from SSD (ms)'); ylabel('Frequency (Hz)')
   
end

