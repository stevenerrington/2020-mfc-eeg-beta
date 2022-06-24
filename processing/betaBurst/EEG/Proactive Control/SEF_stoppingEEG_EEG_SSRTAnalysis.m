dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

for session = 1:29
    midSSD = executiveBeh.midSSDindex(session);
    
    ttx.midSSD.canc{session} = executiveBeh.ttm_c.C{session,midSSD}.all;
%     ttx.midSSD.nostop{session} = executiveBeh.ttm_CGO{session,midSSD}.GO_matched;
    ttx.midSSD.nostop{session} = executiveBeh.ttm_c.NC{session,midSSD}.all;
end

%%

burstTiming.stopSignal.canc = SEF_stoppingEEG_getAverageBurstTime_postSSRT(1:29,...
    ttx.midSSD.canc,FileNames, bayesianSSRT, [50 150], 'stopSignal');
burstTiming.stopSignal.nostop = SEF_stoppingEEG_getAverageBurstTime_postSSRT(1:29,...
    ttx.midSSD.nostop,FileNames, bayesianSSRT, [50 150], 'stopSignal');


canc_stopping_pBurst = burstTiming.stopSignal.canc.pTrials_burst;
nostop_stopping_pBurst = burstTiming.stopSignal.nostop.pTrials_burst;

groupLabels_stopping = [repmat({'No-stop'},29,1); repmat({'Canceled'},29,1)];
burstData_stopping = [nostop_stopping_pBurst; canc_stopping_pBurst];

cancTimes_stopSignal = []; nostopTimes_stopSignal = [];

for session = 1:29
    cancTimes_stopSignal = [cancTimes_stopSignal;burstTiming.stopSignal.canc.burstTimes{session}];
    nostopTimes_stopSignal = [nostopTimes_stopSignal;burstTiming.stopSignal.nostop.burstTimes{session}];
end

clear alltrialLabels_stopSignal
alltrialLabels_stopSignal = [repmat({'Non-canceled'},length(nostopTimes_stopSignal),1);...
    repmat({'Canceled'},length(cancTimes_stopSignal),1)];


%% Export data for stats in JASP
session = [1:29]'; monkey = executiveBeh.nhpSessions.monkeyNameLabel;
postSSRT_BetaBurstData = table(session, monkey, canc_stopping_pBurst,nostop_stopping_pBurst);

writetable(postSSRT_BetaBurstData,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\workingFolder\exportJASP\EEG_pBurst_postSSRT.csv','WriteRowNames',true)


%%

clear betaConvolved
for eventType = [3]
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
    timeWin = 1000+round([bayesianSSRT.ssrt_mean(session)-500 : bayesianSSRT.ssrt_mean(session)+1000]);
    betaValues.canceled{session} = nanmean(betaConvolved.stopSignal{session}(ttx.midSSD.canc{session},timeWin));
    betaValues.nostop{session} = nanmean(betaConvolved.stopSignal{session}(ttx.midSSD.nostop{session},timeWin));
end



%% Create figure
clear burstTime_rasterPlot
histogramPeriod = [-250:50:500];
time = [-500:1000];

burstTime_rasterPlot(1,1)= gramm('x',groupLabels_stopping,'y',burstData_stopping,'color',groupLabels_stopping);
burstTime_rasterPlot(2,1) = gramm('x',[nostopTimes_stopSignal; cancTimes_stopSignal],'color',alltrialLabels_stopSignal);
burstTime_rasterPlot(3,1) = gramm('x',time,'y',[betaValues.nostop'; betaValues.canceled'],...
    'color',groupLabels_stopping); 


burstTime_rasterPlot(1,1).stat_boxplot();
burstTime_rasterPlot(1,1).geom_jitter('alpha',0.5,'dodge',0.75);
burstTime_rasterPlot(2,1).geom_raster('geom','point');
burstTime_rasterPlot(3,1).stat_summary()

burstTime_rasterPlot(2,1).set_point_options('base_size',1);
burstTime_rasterPlot(1,1).no_legend(); 
burstTime_rasterPlot(2,1).no_legend(); 
burstTime_rasterPlot(3,1).no_legend(); 

burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot.set_color_options('map',[colors.canceled;colors.noncanc]);
burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot(3,1).axe_property('XLim',[-250 500]); 
burstTime_rasterPlot(3,1).axe_property('YLim',[0.00025 0.0025]);

figure('Renderer', 'painters', 'Position', [100 100 250 500]);
burstTime_rasterPlot.draw();


ttest(nostop_stopping_pBurst, canc_stopping_pBurst)
mean([nostop_stopping_pBurst, canc_stopping_pBurst])



