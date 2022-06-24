dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';


clear burstTiming

burstTiming.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO, FileNames, bayesianSSRT,[-200 0],'saccade');

for session = 1:29
    burstTiming.nostop.meanRT(session) = nanmean(executiveBeh.RTdata.RTinfo.all{session}.goRT.dist);

    clear noBurstIdx burstIdx sessionRT
    noBurstIdx = executiveBeh.ttx.GO{session}(find(cellfun(@isempty,burstTiming.nostop.burstTimes{session})));
    burstIdx = executiveBeh.ttx.GO{session}(find(~cellfun(@isempty,burstTiming.nostop.burstTimes{session})));
    
    sessionRT = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    burst_noburst_comparison(session,:) = [nanmean(sessionRT(noBurstIdx)), nanmean(sessionRT(burstIdx))];

    test(session,1) = ttest2(sessionRT(noBurstIdx), sessionRT(burstIdx));
    
end




clear g
g(1,1)=gramm('x',burstTiming.nostop.pTrials_burst,'y',burstTiming.nostop.meanRT, 'color', executiveBeh.nhpSessions.monkeyNameLabel);
g(1,1).geom_point();
g(1,1).stat_glm('fullrange',true,'disp_fit',true);
g.set_names('x','p (burst | trial)','y','RT slowing index');
figure('Position',[100 100 300 275]);
g.draw();
