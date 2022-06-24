dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

clear burstTiming
for session = 1:29
    midSSD = executiveBeh.midSSDindex(session);
    
    ttx.midSSD.noncanc{session} = executiveBeh.ttm_c.NC{session,midSSD}.all;
    ttx.midSSD.nostop{session} = executiveBeh.ttm_c.GO_NC{session,midSSD}.all;
end


%% Get burst time proportions for
%  Non-canceled trials (target and stop signal)
burstTiming.saccade.noncanc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttx.midSSD.noncanc,FileNames, bayesianSSRT, [100 300], 'saccade');

%  No-stop trials (target and stop signal)
burstTiming.saccade.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttx.midSSD.nostop,FileNames, bayesianSSRT, [100 300], 'saccade');


a(1,1) = mean(burstTiming.saccade.nostop.pTrials_burst)
a(1,2) = mean(burstTiming.saccade.noncanc.pTrials_burst)


a(2,1) = median(burstTiming.saccade.nostop.pTrials_burst)
a(2,2) = median(burstTiming.saccade.noncanc.pTrials_burst)

%% Concatenate across all sessions
noncancTimes_saccade = []; nostopTimes_saccade = [];

for session = 1:29
    noncancTimes_saccade = [noncancTimes_saccade;burstTiming.saccade.noncanc.burstTimes{session}];
    nostopTimes_saccade = [nostopTimes_saccade;burstTiming.saccade.nostop.burstTimes{session}];
end

allBurstTimes_saccade = [nostopTimes_saccade;noncancTimes_saccade];

%% 
clear betaConvolved
for eventType = [4]
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
    betaValues.saccade.noncanc{session} = nanmean(betaConvolved.saccade{session}(ttx.midSSD.noncanc{session},:));
    betaValues.saccade.nostop{session} = nanmean(betaConvolved.saccade{session}(ttx.midSSD.nostop{session},:));
end

%%  Get labels

alltrialLabels_saccade = [repmat({'No-stop'},length(nostopTimes_saccade),1);...
    repmat({'Non-canceled'},length(noncancTimes_saccade),1)];
%%

clear pBurst_trialType groupLabels epochLabels burstData
sessionList = 1:29;
groupLabels = [repmat({'No-stop'},length(sessionList),1); repmat({'Non-canceled'},length(sessionList),1)];
burstData = [burstTiming.saccade.nostop.pTrials_burst;burstTiming.saccade.noncanc.pTrials_burst];

median(burstTiming.saccade.nostop.pTrials_burst)
median(burstTiming.saccade.noncanc.pTrials_burst)

max(burstTiming.saccade.nostop.pTrials_burst)
max(burstTiming.saccade.noncanc.pTrials_burst)

%% Create figure
clear burstTime_rasterPlot
histogramPeriod = [-250:50:500];
time = [-1000:2000];

burstTime_rasterPlot(1,1)= gramm('x',groupLabels,'y',burstData,'color',groupLabels);
burstTime_rasterPlot(2,1) = gramm('x',allBurstTimes_saccade,'color',alltrialLabels_saccade);
burstTime_rasterPlot(3,1) = gramm('x',time,'y',[betaValues.saccade.nostop';betaValues.saccade.noncanc'],...
    'color',[repmat({'No-stop'},29,1);repmat({'Non-canceled'},29,1)]); 


% burstTime_rasterPlot(1,1).stat_boxplot();
burstTime_rasterPlot(1,1).geom_jitter('alpha',0.5,'dodge',0.75);
burstTime_rasterPlot(2,1).geom_raster('geom','point');
burstTime_rasterPlot(3,1).stat_summary()

burstTime_rasterPlot(2,1).set_point_options('base_size',1);
burstTime_rasterPlot(1,1).no_legend(); 
burstTime_rasterPlot(2,1).no_legend(); 
burstTime_rasterPlot(3,1).no_legend(); 

burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot.set_color_options('map',[colors.nostop;colors.noncanc]);
burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot(3,1).axe_property('XLim',[-250 500]); 
burstTime_rasterPlot(3,1).axe_property('YLim',[0.00025 0.0025]);

figure('Renderer', 'painters', 'Position', [100 100 250 500]);
burstTime_rasterPlot.draw();




