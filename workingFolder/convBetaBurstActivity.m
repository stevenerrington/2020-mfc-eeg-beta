clear betaConvolved
for eventType = [3,4]
    eventLabel = eventNames{eventType};
    for session = 1:29
        sessionName = FileNames{session};
        fprintf('...analysing beta-bursts on session number %i of 29. \n',session);
       
        betaName = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_' eventLabel];
        clear betaOutput; load(['C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\' betaName])
        
        betaConvolved.(eventLabel){session} = BetaBurstConvolver (betaOutput.burstData.burstTime);
    end
end


clear betaValues
for session = 1:29
    betaValues.canceled{session} = nanmean(betaConvolved.s{session}(executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.C_matched,:));
    betaValues.nostop{session} = nanmean(betaConvolved.stopSignal{session}(executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.GO_matched,:));
end

time = [-1000:2000];

clear g
g(1,1)=gramm('x',time,'y',...
    [betaValues.canceled';betaValues.nostop'],...
    'color',[repmat({'canceled'},29,1);repmat({'no-stop'},29,1)]); % Inhibition function
g(1,1).stat_summary()
g(1,1).set_color_options('map',[colors.canceled; colors.nostop]);
g(1,1).axe_property('XLim',[-250 500]); g(1,1).axe_property('YLim',[0 0.003]);
figure('Position',[100 100 450 400]);
g.draw();






%% ALL TRIAL TYPES
clear betaValues
for session = 1:29
    betaValues.canceled{session} = nanmean(betaConvolved.stopSignal{session}(executiveBeh.ttx_canc{session},:));
    betaValues.noncanceled{session} = nanmean(betaConvolved.stopSignal{session}(executiveBeh.ttx.NC{session},:));
    betaValues.nostop{session} = nanmean(betaConvolved.stopSignal{session}(executiveBeh.ttx.GO{session},:));
end

time = [-1000:2000];

clear g
g(1,1)=gramm('x',time,'y',...
    [betaValues.canceled';betaValues.noncanceled';betaValues.nostop'],...
    'color',[repmat({'canceled'},29,1);repmat({'non-canc'},29,1);repmat({'no-stop'},29,1)]); % Inhibition function
g(1,1).stat_summary()
g(1,1).set_color_options('map',[colors.canceled; colors.nostop; colors.noncanc]);
g(1,1).axe_property('XLim',[-250 500]); g(1,1).axe_property('YLim',[0 0.003]);
figure('Position',[100 100 450 400]);
g.draw();
