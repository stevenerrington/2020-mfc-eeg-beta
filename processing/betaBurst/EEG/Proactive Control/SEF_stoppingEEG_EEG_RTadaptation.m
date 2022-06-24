dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';


for session = 1:29
trialHistoryIdx.noncanc_go{session} = executiveBeh.Trials.all{session}.t_NC_before_GO;
trialHistoryIdx.go_go{session} = executiveBeh.Trials.all{session}.t_GO_before_GO;
end

clear burstTiming

burstTiming.noncanc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    trialHistoryIdx.noncanc_go,FileNames, bayesianSSRT,[100 300],'saccade');

burstTiming.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    trialHistoryIdx.go_go,FileNames, bayesianSSRT,[100 300],'saccade');

for session = 1:29
    burstTiming.nostop.meanRT(session) = nanmean(executiveBeh.RTdata.RTinfo.all{session}.goRT.dist);
    burstTiming.noncanc.meanRT(session) = nanmean(executiveBeh.RTdata.RTinfo.all{session}.ncRT.dist);
end

for session = 1:29
 postError_slowingIdx(session, 1) =...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_NC)./...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_GO);

     postCancel_slowingIdx(session, 1) =...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_C)./...
        nanmean(executiveBeh.RTdata.RThistory.all{session}.GO_after_GO);

end

%%

rtAdjustmentIndex(1,1)= gramm('x',[repmat({'Post-Error'},29,1); repmat({'Post-Stopping'},29,1)],...
    'y',[postError_slowingIdx; postCancel_slowingIdx],'color',...
    [executiveBeh.nhpSessions.monkeyNameLabel; executiveBeh.nhpSessions.monkeyNameLabel] );

rtAdjustmentIndex(1,1).stat_boxplot();
rtAdjustmentIndex(1,1).geom_jitter('alpha',0.5,'dodge',0.75);

rtAdjustmentIndex.set_color_options('map','d3.schemePaired');

figure('Renderer', 'painters', 'Position', [100 100 400 300]);
rtAdjustmentIndex.draw();

%%

rtAdjustment_pBurst(1,1)= gramm('x',postError_slowingIdx,...
    'y',burstTiming.noncanc.pTrials_burst,'color',...
    executiveBeh.nhpSessions.monkeyNameLabel);
rtAdjustment_pBurst(1,1).geom_point();
rtAdjustment_pBurst(1,1).stat_glm('fullrange',true,'disp_fit',true);
rtAdjustment_pBurst.set_color_options('map',[colors.euler; colors.xena]);
rtAdjustment_pBurst(1,1).axe_property('YLim',[-0.05 0.25]);

figure('Renderer', 'painters', 'Position', [100 100 300 250]);
rtAdjustment_pBurst.draw();


%%

testA = postError_slowingIdx(executiveBeh.nhpSessions.XSessions)
testB = burstTiming.noncanc.pTrials_burst(executiveBeh.nhpSessions.XSessions)

testTable = table(testA,testB)
writetable(testTable,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\test.csv','WriteRowNames',true)