

% Alignment parameters
alignWin = [-1000 2000];
baselineWinSize = 300;
baselineWin = abs(alignWin)-baselineWinSize: abs(alignWin);
samplingFreq = 1000;
filt_order = 2;

% Filtering parameters
filterBands.all = [1 120];
filterBands.delta = [1 4];
filterBands.theta = [4 9];
filterBands.alpha = [9 15];
filterBands.beta = [15 30];
filterBands.lowGamma = [30 60];
filterBands.highGamma = [60 120];

filterNames = fieldnames(filterBands);
eventNames = {'fixate','target','stopSignal','saccade','sacc_end','tone','reward','sec_sacc'};
% Storage information
outputDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\extractedLFP\';

% For each session
for session = 14%:29
    sessionName = FileNames{session};
    
    % Load the LFP channels recorded for that session
    fprintf('Analysing session %d of %d... \n', session, 29);
    inputLFP = load(['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2012_Cmand_EuX\rawData\' sessionName],...
        'AD1*','AD2*','AD3*','AD4*');
   
    lfpChannels = fieldnames(inputLFP);
%     validChannels = sessionInformation.LFPRange...
%         (find(sessionInformation.session == session),:);
%     lfpChannels = lfpChannels(validChannels(1):validChannels(2)); 
    
    % Get event timinings
    TrialEventTimes_session = executiveBeh.TrialEventTimes_Overall{session};
    
    % For each channel
    for k=1:numel(lfpChannels)
        if (isnumeric(inputLFP.(lfpChannels{k})))
            fprintf('Analysing LFP %d of %d... \n', k, numel(lfpChannels));
            
            % Get the raw data.
            unfilteredSignal = inputLFP.(lfpChannels{k});
            
            % 
            [powerSpectrum{k,1}, betaBurst{k,1}] =...
                SEF_LFP_morletWaveletAnalysis(unfilteredSignal, session, executiveBeh, bayesianSSRT);

            
%             % For each filter band
%             for filterIdx = 1:numel(filterNames)
%                 bandName = filterNames{filterIdx};
%                 bandFrequency = filterBands.(bandName);
%                 
%                 filteredSignal.(bandName) =...
%                     SEF_LFP_Filter(unfilteredSignal,bandFrequency(1),...
%                     bandFrequency(2), samplingFreq);
% 
%                 
%                 for eventIdx = [2 3 4 6 7]
%                     event = eventNames{eventIdx};
%                     [LFPdata.(bandName).(event)] =...
%                         SDFaligner_4FixationBreak(filteredSignal.(bandName),...
%                         1:size(TrialEventTimes_session,1),...
%                         TrialEventTimes_session, eventIdx, alignWin);
%                 end
%                 
%                 
%             end
%             
%             LFPdata.filterBands = filterBands;
%             LFPdata.alignWin = alignWin;
%             
%             
%             savename = ['lfp_session' int2str(session) '_' lfpChannels{k}];
%             
%             save([outputDir savename],'LFPdata','-v7.3')
%             
            
        end
    end
    
    clear lfpChannels inputLFP filteredSignal
    
end

toc