figure('Renderer', 'painters', 'Position', [100 100 1000 800]);

filterNames = fieldnames(LFPdata);
eventNames = fieldnames(LFPdata.all);
session = 14;

ssdIdx = executiveBeh.midSSDarray(session,2);
trials = executiveBeh.ttm_CGO{session,ssdIdx}.C_matched ;
window = [500:2000];

count = 0;
for filterIdx = 1:numel(filterNames)
    bandName = filterNames{filterIdx};
    
    for eventIdx = 1:numel(eventNames)
        count = count + 1;
        event = eventNames{eventIdx};
        
        clear inputData
        inputData = LFPdata.(bandName).(event);
        
        subplot(numel(filterNames),numel(eventNames),count)
        plot(nanmean(inputData(trials,window)))
        vline(window(1),'r-');
        vline(window(1)+executiveBeh.SSRT_integrationWeighted_all(session),'r--');

        title(bandName)
    end
    
end

event = 'stopSignal';

inputData = LFPdata.all.(event);
averageData = nanmean(inputData(trials,window));

figure;
subplot(3,1,1)
plot(averageData)

subplot(3,1,2)
pspectrum(averageData,1000,'Leakage',1)

subplot(3,1,3)
pspectrum(averageData,1000,'spectrogram')
ylim([0 50])


a = normSignalPower(trials.canceled(2),:);
b = mean(squeeze(morletLFP(trials.canceled(2),:,:)),2);

time = [-1000:1999];

figure; subplot(2,1,1); plot(time,a); title('Absolute power method');
subplot(2,1,2); plot(time,b); title('Morlet transform method');






%% 

betaLFP_canc = nanmean(alignedLFP(trials.canceled,:));
betaLFP_noncanc = nanmean(alignedLFP(trials.noncanceled,:));
betaLFP_nostop = nanmean(alignedLFP(trials.nostop,:));

[~,betaPower_canc,~] = getTrialPower(betaLFP_canc, filterFreq, ephysParameters, [600:800]);    
[~,betaPower_noncanc,~] = getTrialPower(betaLFP_noncanc, filterFreq, ephysParameters, [600:800]);    
[~,betaPower_nostop,~] = getTrialPower(betaLFP_nostop, filterFreq, ephysParameters, [600:800]);    



figure;
subplot(2,1,1); hold on
plot(time,betaLFP_canc); plot(time,betaPower_noncanc); plot(time,betaPower_nostop);
ylabel('Voltage (\muV)')
subplot(2,1,2); hold on
plot(time,betaPower_canc); plot(time,betaPower_noncanc); plot(time,betaPower_nostop);
xlabel('Time from SSD (ms)'); ylabel('Power (a.u.)')

for subplotIdx = 1:2
    subplot(2,1,subplotIdx)
    xlim([-500 1000])
    vline(0,'r'); vline(ssrt,'r--')
    box off
end



