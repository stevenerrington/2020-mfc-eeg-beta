%% Get beta burst information
for eventType = 3
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
        parfor medianCutoff = 1:10
            [betaOutput{medianCutoff}] = betaBurstCount(morletLFP, morletParameters, medianCutoff);
        end
        
        
        % Save output
        savename = ['betaBurst\neurometric\eeg_session' int2str(session) '_' sessionName '_betaOutputNeurometric_' eventLabel];
        save([outputDir savename],'betaOutput','-v7.3')
        
        clear betaOutput morletLFP
        
    end
end


%%

clear pBurst_canc
for session = 1:29
    sessionName = FileNames{session};
    
    clear betaOutput
    loadname = ['betaBurst\neurometric\eeg_session' int2str(session) '_' sessionName '_betaOutputNeurometric_stopSignal'];
    load([outputDir loadname])
    fprintf('...analysing beta-bursts on session number %i of 29. \n',session);
    
    for LFPthreshold = 1:10
        
        for ssdIdx = 1:3
            clear trials
            trials = executiveBeh.ttm_CGO{session,executiveBeh.midSSDarray(session,ssdIdx)}.C_matched;
            
            clear burstFlag
            
            for ii = 1:length(trials)
                burstFlag(ii,1) =...
                    sum(betaOutput{LFPthreshold}.burstData.burstTime{trials(ii)} >...
                    bayesianSSRT.ssrt_mean(session)-50 &...
                    betaOutput{LFPthreshold}.burstData.burstTime{trials(ii)} <= ...
                    bayesianSSRT.ssrt_mean(session)) > 0 ;
            end
            
            pBurst_canc(LFPthreshold,ssdIdx,session) = mean(burstFlag);

        end
        
        
    end
    
end


%%
pBurst_session = mean(pBurst_canc,3);
pBurstTest = [pBurst_session(:,1);pBurst_session(:,2);pBurst_session(:,3)];

clear test
test(1,1)=gramm('x',[[1:10]';[1:10]'],'y',[pBurst_session(:,1);pBurst_session(:,3)],...
    'color',[repmat({'1'},10,1);repmat({'2'},10,1)]);

% Plot SSD x pNC and pBurst
test(1,1).stat_summary()
% test(1,1).no_legend()
test(1,1).axe_property('YLim',[0 0.4]);


figure('Position',[100 100 300 250]);
test.draw();

%%



