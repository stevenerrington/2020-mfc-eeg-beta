% Post SSRT period on canceled trials
dataDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
baselineWin = [-400 -200];
targetWin = [0 200];

for session = 1:29
    
    clear betaOutput baseline_betaBurstFlag target_betaBurstFlag
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Load in beta output data for session
    loadFile = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_target'];
    load([dataDir loadFile]) 
    
    trials = [];
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.sNC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    [betaOutput] = thresholdBursts(betaOutput, betaOutput.medianLFPpower*6);
     
    
    for trl = 1:length(betaOutput.burstData.burstTime)
        baseline_betaBurstFlag(trl,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= baselineWin(1) &...
            betaOutput.burstData.burstTime{trl} <= baselineWin(2)));
        
        target_betaBurstFlag(trl,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= targetWin(1) &...
            betaOutput.burstData.burstTime{trl} <= targetWin(2)));
    end
    
    betaBaseline(session,1) = mean(baseline_betaBurstFlag([trials.nostop; trials.noncanceled; trials.canceled]));
    betaActive(session,1) = mean(target_betaBurstFlag([trials.nostop; trials.noncanceled; trials.canceled]));
end

[mean(betaBaseline), sem(betaBaseline)]*100
[mean(betaActive), std(betaActive)]*100
