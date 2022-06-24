function burstTiming = SEF_stoppingEEG_getAverageBurstTime(sessionList,...
    trialList, FileNames, bayesianSSRT, timeThreshold, event)

dataDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
warning off
burstTiming = table();

for sessionIdx = 1:length(sessionList)
    session = sessionList(sessionIdx);
    clear betaOutput trial_betaBurst_timing burstTimes trialBurstFlag trlBurstTimes
    
    if nargin < 5
        timeThreshold = [0 bayesianSSRT.ssrt_mean(session)]; 
        event = 'stopSignal';
    end
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Save output
    loadFile = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_' event];
    load([dataDir loadFile],'betaOutput')
    [betaOutput] = thresholdBursts_EEG(betaOutput, betaOutput.medianLFPpower*6);
       
    trial_betaBurst_timing = [];
    
    for trlIdx = 1:length(trialList{session})
        trial = trialList{session}(trlIdx);
        trial_betaBurst_timing = [trial_betaBurst_timing;...
            betaOutput.burstData.burstTime{trial}];
        
        trialBurstFlag(trlIdx,1) = sum(betaOutput.burstData.burstTime{trial} > timeThreshold(1) &...
        betaOutput.burstData.burstTime{trial} <= timeThreshold(2)) > 0;
    
        trlBurstTimes{trlIdx,1} = betaOutput.burstData.burstTime{trial}...
            (betaOutput.burstData.burstTime{trial} > -250 &...
            betaOutput.burstData.burstTime{trial} <= 500);
    
    end
    
    burstTimes = trial_betaBurst_timing(trial_betaBurst_timing > timeThreshold(1) &...
        trial_betaBurst_timing <= timeThreshold(2));

    burstTiming.mean_burstTime(sessionIdx) = mean(burstTimes);
    burstTiming.std_burstTime(sessionIdx) = std(burstTimes);
    burstTiming.sem_burstTime(sessionIdx) = std(burstTimes)/...
        sqrt(length(burstTimes));
    
    burstTiming.burstTimes{sessionIdx} = trlBurstTimes;
    
    burstTiming.pTrials_burst(sessionIdx) =...
        sum(trialBurstFlag)./length(trialBurstFlag);


    burstTiming.mean_ssrt(sessionIdx) = bayesianSSRT.ssrt_mean(sessionIdx);
    burstTiming.std_ssrt(sessionIdx) = bayesianSSRT.ssrt_std(sessionIdx);
    burstTiming.triggerFailures(sessionIdx) = bayesianSSRT.triggerFailures(sessionIdx);
       
end




