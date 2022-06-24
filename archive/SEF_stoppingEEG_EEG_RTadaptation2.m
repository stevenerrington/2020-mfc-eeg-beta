RTadaptation = table();

for session = 1:29
    
    monkey = executiveBeh.nhpSessions.monkeyNameLabel(session);
    
    clear RT
    RT = executiveBeh.TrialEventTimes_Overall{session}(:,4) -...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    clear postError postCancel postGo
    postError = nanmean(RT(executiveBeh.Trials.Hi{session}.t_GO_after_NC));
    postCancel = nanmean(RT(executiveBeh.Trials.Hi{session}.t_GO_after_C));
    postGo = nanmean(RT(executiveBeh.Trials.Hi{session}.t_GO_after_GO));
    
    
    RTadaptation(session,:) = table(session, monkey, postGo, postCancel, postError);
    
end

%% JASP OUTPUT
writetable(RTadaptation,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_pBurst_RTadaptation.csv','WriteRowNames',true)

%% 
trialType = [repmat({'No-stop'},29,1);repmat({'Canceled'},29,1);repmat({'Non-Canceled'},29,1)];
RT_session = [RTadaptation.postGo; RTadaptation.postCancel; RTadaptation.postError];
rtAdaptBoxplot(1,1)=gramm('x',trialType,'y',RT_session,'color',trialType);

rtAdaptBoxplot(1,1).stat_boxplot();
rtAdaptBoxplot(1,1).geom_jitter('alpha',0.5);

rtAdaptBoxplot.set_color_options('map',[colors.canceled; colors.nostop; colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 400 300]);
rtAdaptBoxplot.draw();

