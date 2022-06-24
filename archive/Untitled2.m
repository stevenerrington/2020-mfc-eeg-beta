dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

clear burstTiming


for session = 1:29
    
    TType = {2,0,1,0,1,0,0,0};
    ttx_canc_H{session} = SEF_Toolbox_indexExtractor(TType{1}, TType{2}, TType{3},...
        TType{4}, TType{5}, TType{6}, TType{7}, TType{8},...
        executiveBeh.SessionInfo{session}, 0, executiveBeh.TrialEventTimes_Overall{session});
    
    TType = {2,0,1,0,2,0,0,0};
    ttx_canc_L{session} = SEF_Toolbox_indexExtractor(TType{1}, TType{2}, TType{3},...
        TType{4}, TType{5}, TType{6}, TType{7}, TType{8},...
        executiveBeh.SessionInfo{session}, 0, executiveBeh.TrialEventTimes_Overall{session});
end

%% Stopping
burstTiming.canc_H = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttx_canc_H,FileNames, bayesianSSRT);
burstTiming.canc_L = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttx_canc_L,FileNames, bayesianSSRT);

burstTiming.noncanc_H = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC_H,FileNames, bayesianSSRT);
burstTiming.noncanc_L = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC_L,FileNames, bayesianSSRT);

burstTiming.nostop_H = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO_H,FileNames, bayesianSSRT);
burstTiming.nostop_L = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO_L,FileNames, bayesianSSRT);


[h, p, ~, stats] = ttest(burstTiming.canc_H.pTrials_burst,burstTiming.canc_L.pTrials_burst)
[h, p, ~, stats] = ttest(burstTiming.noncanc_H.pTrials_burst,burstTiming.noncanc_L.pTrials_burst)
[h, p, ~, stats] = ttest(burstTiming.nostop_H.pTrials_burst,burstTiming.nostop_L.pTrials_burst)



%% Error
%  Non-canceled trials (target and stop signal)
burstTiming.saccade.noncanc_H = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC_H,FileNames, bayesianSSRT, [100 300], 'saccade');
burstTiming.saccade.noncanc_L = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC_L,FileNames, bayesianSSRT, [100 300], 'saccade');

burstTiming.saccade.nostop_H = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO_H,FileNames, bayesianSSRT, [100 300], 'saccade');
burstTiming.saccade.nostop_L = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO_L,FileNames, bayesianSSRT, [100 300], 'saccade');

[h, p, ~, stats] = ttest(burstTiming.saccade.noncanc_H.pTrials_burst,burstTiming.saccade.noncanc_L.pTrials_burst)
[h, p, ~, stats] = ttest(burstTiming.saccade.nostop_H.pTrials_burst,burstTiming.saccade.nostop_L.pTrials_burst)



%% Behavior
[h, p, ~, stats] = ttest(executiveBeh.ssrt.hiArray,executiveBeh.ssrt.loArray)

