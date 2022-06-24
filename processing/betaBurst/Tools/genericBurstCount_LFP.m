function [pTrl_burst] = genericBurstCount_LFP(betaOutput, trials)


for trlIdx = 1:size(trials,1)
    trl = trials(trlIdx);
    
    baselineWin = [-400 -200];
    targetWin = [0 200];
       
    baselineBetaIdx = find(betaOutput.burstData.burstTime{trl} < baselineWin(2) &...
        betaOutput.burstData.burstTime{trl} > baselineWin(1));
    
    nBaseline_bursts(trlIdx,1) = length(baselineBetaIdx);
    
    targetBetaIdx = find(betaOutput.burstData.burstTime{trl} > targetWin(1) &...
        betaOutput.burstData.burstTime{trl} < targetWin(2));
    
    nTarget_bursts(trlIdx,1) = length(targetBetaIdx);
    
    
end

pTrl_burst.baseline = sum(nBaseline_bursts == 1)./length(trials);
pTrl_burst.target = sum(nTarget_bursts == 1)./length(trials);

