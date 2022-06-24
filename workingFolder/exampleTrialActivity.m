trl = trials.noncanceled(5);


betaFreq = betaOutput.burstData.burstFrequency{trl};
betaTimes = betaOutput.burstData.burstTime{trl};
time = [-999:2000];
freqs = morletParameters.frequencies;

figure('Renderer', 'painters', 'Position', [100 100 500 600]);
subplot(3,1,1)
plot(time,alignedLFP(trl,:),'k')
ylabel('Voltage (\muV)')

subplot(3,1,2)
plot(time,mean(squeeze(morletLFP(trl,:,:))'),'k')
ylabel('Power')

subplot(3,1,3)
imagesc('XData',time,'YData',freqs,'CData',squeeze(morletLFP(trl,:,:))')
xlim([time(1) time(end)]); ylim([freqs(1) freqs(end)]);
hold on
scatter(betaTimes,betaFreq,'ko')
xlabel('Time from SSD (ms)'); ylabel('Frequency (Hz)')



for subplotIdx = 1:3
    subplot(3,1,subplotIdx)
    vline(0,'r-'); vline(ssrt,'r--'); %xlim([-250 500]);
    box off
end
