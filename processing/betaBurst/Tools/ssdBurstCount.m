function [pTrl_burst] = ssdBurstCount(betaOutput, ssrt, trials, session, executiveBeh)


for trl = 1:size(betaOutput.burstData,1)
    
    targetTime = executiveBeh.TrialEventTimes_Overall{session}(trl,3)-...
        executiveBeh.TrialEventTimes_Overall{session}(trl,2);
    
    baselineWin_target = [-200-ssrt, -200];
    baselineWin_ssd = baselineWin_target + -targetTime;
   
    baselineBetaIdx = find(betaOutput.burstData.burstTime{trl} < baselineWin_ssd(2) &...
        betaOutput.burstData.burstTime{trl} > baselineWin_ssd(1));
    
    nBaseline_bursts(trl,1) = length(baselineBetaIdx);
    
    ssdBetaIdx = find(betaOutput.burstData.burstTime{trl} > 0 &...
        betaOutput.burstData.burstTime{trl} < ssrt);
    
    nSSD_bursts(trl,1) = length(ssdBetaIdx);
    
    ssrtBetaIdx = find(betaOutput.burstData.burstTime{trl} > ssrt &...
        betaOutput.burstData.burstTime{trl} < ssrt+500);
    
    nSSRT_bursts(trl,1) = length(ssrtBetaIdx);
    
end

pTrl_burst.baseline.canceled = sum(nBaseline_bursts(trials.canceled) == 1)./length(trials.canceled);
pTrl_burst.baseline.noncanc = sum(nBaseline_bursts(trials.noncanceled) == 1)./length(trials.noncanceled);
pTrl_burst.baseline.nostop = sum(nBaseline_bursts(trials.nostop) == 1)./length(trials.nostop);

pTrl_burst.ssd.canceled = sum(nSSD_bursts(trials.canceled) == 1)./length(trials.canceled);
pTrl_burst.ssd.noncanc = sum(nSSD_bursts(trials.noncanceled) == 1)./length(trials.noncanceled);
pTrl_burst.ssd.nostop = sum(nSSD_bursts(trials.nostop) == 1)./length(trials.nostop);

pTrl_burst.ssrt.canceled = sum(nSSRT_bursts(trials.canceled) == 1)./length(trials.canceled);
pTrl_burst.ssrt.noncanc = sum(nSSRT_bursts(trials.noncanceled) == 1)./length(trials.noncanceled);
pTrl_burst.ssrt.nostop = sum(nSSRT_bursts(trials.nostop) == 1)./length(trials.nostop);