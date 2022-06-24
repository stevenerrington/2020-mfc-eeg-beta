

SessionBDF = BetaBurstConvolver (betaOutput.burstData.burstTime);
time = [-1000:2000];

figure
plot(time,nanmean(SessionBDF(executiveBeh.ttx_canc{14},:))); hold on
plot(time,nanmean(SessionBDF(executiveBeh.ttx.GO{14},:))); hold on
plot(time,nanmean(SessionBDF(executiveBeh.ttx.NC{14},:)))
xlim([-250 500]); vline(0,'k'); 
vline(executiveBeh.inh_SSD{14}(executiveBeh.midSSDindex(14)),'r-');
vline(executiveBeh.inh_SSD{14}(executiveBeh.midSSDindex(14))+bayesianSSRT.ssrt_mean(14),'r--');

