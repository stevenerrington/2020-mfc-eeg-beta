outputDir = 'D:\projectCode\project_stoppingEEG\data\monkeyEEG\';
% Load parameters for analysis
getAnalysisParameters; % Separate script holding all key parameters.
        
for eventType = [1,2,3,4,6]
    eventLabel = eventNames{eventType};
    alignmentParameters.eventN = eventType;
    fprintf(['Analysing data aligned on ' eventLabel '. \n']);
    
    %% Extract EEG data & calculate power
    for session = 1:29
        fprintf('...extracting beta on session number %i of 29. \n',session);
        % Get session name (to load in relevant file)
        sessionName = FileNames{session};
        
        % Clear workspace
        clear trials eventTimes inputLFP cleanLFP alignedLFP filteredLFP betaOutput morletLFP pTrl_burst
        
        % Setup key behavior variables
        ssrt = bayesianSSRT.ssrt_mean(session);
        eventTimes = executiveBeh.TrialEventTimes_Overall{session};
        
        % Get trial indices
        trials.canceled = executiveBeh.ttm_CGO{session}.C_unmatched;
        trials.noncanceled = executiveBeh.ttx.NC{session};
        trials.nostop = executiveBeh.ttx.GO{session};
        
        % Load raw signal
        inputLFP = load(['D:\data\2012_Cmand_EuX\rawData\' sessionName],...
            'AD01');
        
        % Pre-process & filter analog data (EEG/LFP), and align on event
        filter = 'all';
        filterFreq = filterBands.(filter);
        [cleanLFP, filteredLFP.(filter)] = tidyRawSignal(inputLFP.AD01, ephysParameters, filterFreq,...
            eventTimes, alignmentParameters);
        
        filter = 'beta';
        filterFreq = filterBands.(filter);
        [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.AD01, ephysParameters, filterFreq,...
            eventTimes, alignmentParameters);
        
        filter = 'lowGamma';
        filterFreq = filterBands.(filter);
        [~, filteredLFP.(filter)] = tidyRawSignal(inputLFP.AD01, ephysParameters, filterFreq,...
            eventTimes, alignmentParameters);
        
        % Calculate power within the extracted band:
        % (a) Using absolute method (i.e. Westerberg/Maier suggestion)
        %     [signalPower,adjSignalPower, normSignalPower] = getTrialPower(alignedLFP, filterFreq, ephysParameters, [600:800]);
        
        % (b) Convolve using Morlet Wave Transformation, calculate power, and determine
        % bursts in data (i.e. Wessel, 2020, JNeurosci)
        [morletLFP] = convMorletWaveform(filteredLFP.all,morletParameters);
        
        savename = ['morletData\eeg_session' int2str(session) '_' sessionName '_morlet_' eventLabel];
        save([outputDir savename],'filteredLFP','morletLFP','-v7.3')
        clear trials eventTimes inputLFP cleanLFP alignedLFP filteredLFP betaOutput morletLFP pTrl_burst
        
    end
end

%% Get beta burst information
for eventType = [1,2,3,4,6]
    eventLabel = eventNames{eventType};
    alignmentParameters.eventN = eventType;
    fprintf(['Analysing data aligned on ' eventLabel '. \n']);
    for session = 1:29
        
        clear betaOutput morletLFP
        
        % Get session name (to load in relevant file)
        sessionName = FileNames{session};
        fprintf('...analysing beta-bursts on session number %i of 29. \n',session);
        
        % Load in morlet transformed data
        loadname = ['morletData\eeg_session' int2str(session) '_' sessionName '_morlet_' eventLabel];
        load([outputDir loadname],'filteredLFP','morletLFP')
        
        % Get beta bursts
        [betaOutput] = betaBurstCount(morletLFP, morletParameters);
        
        % Save output
        savename = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_' eventLabel];
        save([outputDir savename],'betaOutput','-v7.3')
        
        clear betaOutput morletLFP
        
    end
    
    
end



%% Calculate proportion of trials with burst

for session = 1:29
    
    clear betaOutput pTrl_burst ssrt trials
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Load in beta output data for session
    loadname = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_target'];
    load([outputDir loadname],'betaOutput')
    
    % Get behavioral information
    ssrt = bayesianSSRT.ssrt_mean(session);
    trials.canceled = executiveBeh.ttx_canc{session};
    trials.noncanceled = executiveBeh.ttx.NC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
%     
%     % Calculate p(trials) with burst
%     [pTrl_burst] = ssdBurstCount(betaOutput, ssrt, trials, session, executiveBeh);
%     
%     % Calculate p(trials) with burst
%     savename = ['pBurst\eeg_session' int2str(session) '_' sessionName 'pTrl_burst'];
%     save([outputDir savename],'pTrl_burst','-v7.3')
%     
%     
    
    for trl = 1:length(betaOutput.burstData.burstTime)
        baseline_betaBurstFlag(trl,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= baselineWin(1) &...
            betaOutput.burstData.burstTime{trl} <= baselineWin(2)));
        
        target_betaBurstFlag(trl,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= targetWin(1) &...
            betaOutput.burstData.burstTime{trl} <= targetWin(2)));
    end
    
    betaBaseline_EEG(session,1) = mean(baseline_betaBurstFlag([trials.nostop; trials.noncanceled; trials.canceled]));
    betaActive_EEG(session,1) = mean(target_betaBurstFlag([trials.nostop; trials.noncanceled; trials.canceled]));
    
    
end

[mean(betaBaseline_EEG), sem(betaBaseline_EEG)]*100
[mean(betaActive_EEG), sem(betaActive_EEG)]*100