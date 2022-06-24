function burstTiming = SEF_stoppingEEG_getAverageBurstTime_postSSRT(sessionList,...
    trialList, FileNames, bayesianSSRT, window, event)

dataDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
warning off
burstTiming = table();

if nargin < 5
    window = [0 300];
    event = 'stopSignal';
end

for sessionIdx = 1:length(sessionList)
    session = sessionList(sessionIdx);
    clear betaOutput trial_betaBurst_timing burstTimes trialBurstFlag trlBurstTimes
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Save output
    loadFile = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_' event];
    load([dataDir loadFile],'betaOutput')
    
    trial_betaBurst_timing = [];
    inputBurstTimes = betaOutput.burstData.burstTime;
    inputBurstTimes = cellfun(@(x) x-bayesianSSRT.ssrt_mean(session),inputBurstTimes,'un',0);
    
    
    for trlIdx = 1:length(trialList{session})
        trial = trialList{session}(trlIdx);
        trial_betaBurst_timing = [trial_betaBurst_timing;...
            inputBurstTimes{trial}];
                
        trialBurstFlag(trlIdx,1) = sum(inputBurstTimes{trial} > window(1) &...
            inputBurstTimes{trial} <= window(2)) > 0;
        
        trlBurstTimes{trlIdx,1} = inputBurstTimes{trial}...
            (inputBurstTimes{trial} > -250 & inputBurstTimes{trial} <= 500);
        
    end
    
    burstTimes = trial_betaBurst_timing(trial_betaBurst_timing > window(1) &...
        trial_betaBurst_timing <= window(2));
    
    burstTiming.mean_burstTime(sessionIdx) = mean(burstTimes);
    burstTiming.std_burstTime(sessionIdx) = std(burstTimes);
    burstTiming.sem_burstTime(sessionIdx) = std(burstTimes)/...
        sqrt(length(burstTimes));
    
    burstTiming.burstTimes{sessionIdx} = trlBurstTimes;
    
    burstTiming.pTrials_burst(sessionIdx) =...
        sum(trialBurstFlag)./length(trialBurstFlag);
    
    
end




