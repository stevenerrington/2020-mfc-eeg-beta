function [pTrl_burst] = saccadeBurstCount_LFP(betaOutput, trials, session, executiveBeh, window)


for trl = 1:size(betaOutput.burstData,1)
    
    targetTime = executiveBeh.TrialEventTimes_Overall{session}(trl,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(trl,2);
    
    baselineWin_target = [-200-200, -200];
    baselineWin_ssd = baselineWin_target + -targetTime;
   
    baselineBetaIdx = find(betaOutput.burstData.burstTime{trl} < baselineWin_ssd(2) &...
        betaOutput.burstData.burstTime{trl} > baselineWin_ssd(1));
    
    nBaseline_bursts(trl,1) = length(baselineBetaIdx);
    
    saccadeBetaIdx = find(betaOutput.burstData.burstTime{trl} > window(1)-1 &...
        betaOutput.burstData.burstTime{trl} < window(2)+1);
    
    nSaccade_bursts(trl,1) = length(saccadeBetaIdx);
    
    
end

pTrl_burst.baseline.noncanc = sum(nBaseline_bursts(trials.noncanceled) == 1)./length(trials.noncanceled);
pTrl_burst.baseline.nostop = sum(nBaseline_bursts(trials.nostop) == 1)./length(trials.nostop);

pTrl_burst.saccade.noncanc = sum(nSaccade_bursts(trials.noncanceled) == 1)./length(trials.noncanceled);
pTrl_burst.saccade.nostop = sum(nSaccade_bursts(trials.nostop) == 1)./length(trials.nostop);
