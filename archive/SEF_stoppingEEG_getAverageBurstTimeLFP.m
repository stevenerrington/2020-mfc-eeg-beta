function burstTiming = SEF_stoppingEEG_getAverageBurstTimeLFP(session, trialList, betaBurst, bayesianSSRT, timeThreshold)

burstTiming = table();
warning off

clear trial_betaBurst_timing burstTimes trialBurstFlag trlBurstTimes

if nargin < 5
    timeThreshold = [0 bayesianSSRT.ssrt_mean(session)];
end

trial_betaBurst_timing = [];

for trlIdx = 1:length(trialList{session})
    trial = trialList{session}(trlIdx);
    trial_betaBurst_timing = [trial_betaBurst_timing;...
        betaBurst.burstData.burstTime{trial}];
    
    trialBurstFlag(trlIdx,1) = sum(betaBurst.burstData.burstTime{trial} > timeThreshold(1) &...
        betaBurst.burstData.burstTime{trial} <= timeThreshold(2)) > 0;
    
    trlBurstTimes{trlIdx,1} = betaBurst.burstData.burstTime{trial}...
        (betaBurst.burstData.burstTime{trial} > -250 &...
        betaBurst.burstData.burstTime{trial} <= 500);
    
end

burstTimes = trial_betaBurst_timing(trial_betaBurst_timing > timeThreshold(1) &...
    trial_betaBurst_timing <= timeThreshold(2));

burstTiming.mean_burstTime = mean(burstTimes);
burstTiming.std_burstTime = std(burstTimes);
burstTiming.sem_burstTime = std(burstTimes)/...
    sqrt(length(burstTimes));

burstTiming.burstTimes = {trlBurstTimes};

burstTiming.pTrials_burst =...
    sum(trialBurstFlag)./length(trialBurstFlag);


burstTiming.mean_ssrt = bayesianSSRT.ssrt_mean(session);
burstTiming.std_ssrt = bayesianSSRT.ssrt_std(session);
burstTiming.triggerFailures = bayesianSSRT.triggerFailures(session);




