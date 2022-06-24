dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

clear burstTiming

burstTiming.target.canc = SEF_stoppingEEG_getAverageBurstTimeBaseline(1:29,...
    executiveBeh.ttx_canc,FileNames, bayesianSSRT, [-200 -400],'target');
burstTiming.target.noncanc = SEF_stoppingEEG_getAverageBurstTimeBaseline(1:29,...
    executiveBeh.ttx.NC,FileNames, bayesianSSRT, [-200 -400],'target');
burstTiming.target.nostop = SEF_stoppingEEG_getAverageBurstTimeBaseline(1:29,...
    executiveBeh.ttx.GO,FileNames, bayesianSSRT, [-200 -400],'target');

burstTiming.stopSignal.canc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx_canc,FileNames, bayesianSSRT);
burstTiming.stopSignal.noncanc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC,FileNames, bayesianSSRT);
burstTiming.stopSignal.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO,FileNames, bayesianSSRT);

burstTiming.saccade.noncanc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC,FileNames, bayesianSSRT, [-200 200],'saccade');
burstTiming.saccade.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO,FileNames, bayesianSSRT, [-200 200],'saccade');
%% Concatenate across all sessions
cancTimes_stopSignal = []; noncancTimes_stopSignal = []; nostopTimes_stopSignal = [];
cancTimes_target = []; noncancTimes_target = []; nostopTimes_target = []; 
noncancTimes_saccade = []; nostopTimes_saccade = []; 

for session = 1:29
    cancTimes_target = [cancTimes_target;burstTiming.target.canc.burstTimes{session}];
    noncancTimes_target = [noncancTimes_target;burstTiming.target.noncanc.burstTimes{session}];
    nostopTimes_target = [nostopTimes_target;burstTiming.target.nostop.burstTimes{session}];
    
    cancTimes_stopSignal = [cancTimes_stopSignal;burstTiming.stopSignal.canc.burstTimes{session}];
    noncancTimes_stopSignal = [noncancTimes_stopSignal;burstTiming.stopSignal.noncanc.burstTimes{session}];
    nostopTimes_stopSignal = [nostopTimes_stopSignal;burstTiming.stopSignal.nostop.burstTimes{session}];

    noncancTimes_saccade = [noncancTimes_saccade;burstTiming.saccade.noncanc.burstTimes{session}];
    nostopTimes_saccade = [nostopTimes_saccade;burstTiming.saccade.nostop.burstTimes{session}];
end

%% Convolve pBetaBurst

clear betaConvolved
for eventType = [2 3 4]
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
for eventType = [2 3 4]
    eventLabel = eventNames{eventType};
    for session = 1:29
        betaValues.(eventLabel).canceled{session} = nanmean(betaConvolved.(eventLabel){session}(executiveBeh.ttx_canc{session},:));
        betaValues.(eventLabel).noncanc{session} = nanmean(betaConvolved.(eventLabel){session}(executiveBeh.ttx.NC{session},:));
        betaValues.(eventLabel).nostop{session} = nanmean(betaConvolved.(eventLabel){session}(executiveBeh.ttx.GO{session},:));
    end
end


%% Get data from an example session and collapse across all sessions
allBurstTimes_stopSignal = [nostopTimes_stopSignal;noncancTimes_stopSignal;cancTimes_stopSignal];

%%  Get labels
alltrialLabels_stopSignal = [repmat({'No-stop'},length(nostopTimes_stopSignal),1);...
    repmat({'Non-canceled'},length(noncancTimes_stopSignal),1),;...
    repmat({'Canceled'},length(cancTimes_stopSignal),1)];

%% Create figure (stopping)
clear burstTime_rasterPlot

time = [-1000:2000];
histogramPeriod = [-250:50:500];
burstTime_rasterPlot(1,1) = gramm('x',allBurstTimes_stopSignal,'color',alltrialLabels_stopSignal);
burstTime_rasterPlot(2,1)=gramm('x',time,'y',[betaValues.stopSignal.canceled';betaValues.stopSignal.nostop';betaValues.stopSignal.noncanc'],...
    'color',[repmat({'Canceled'},29,1);repmat({'No-stop'},29,1);repmat({'Non-canceled'},29,1)]); 

burstTime_rasterPlot(1,1).geom_raster('geom','point');
burstTime_rasterPlot(1,1).set_point_options('base_size',1);
burstTime_rasterPlot(2,1).stat_summary()

burstTime_rasterPlot(1,1).no_legend(); burstTime_rasterPlot(2,1).no_legend();
burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot(2,1).axe_property('XLim',[-250 500]); 
burstTime_rasterPlot(2,1).axe_property('YLim',[0.00025 0.002]);
burstTime_rasterPlot.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Position',[100 100 300 500]);
burstTime_rasterPlot.draw();

%% Create figure (baseline)
clear burstTime_rasterPlot
% Get data from an example session and collapse across all sessions
allBurstTimes_target = [nostopTimes_target;noncancTimes_target;cancTimes_target];
allBurstTimes_saccade = [nostopTimes_saccade;noncancTimes_saccade];

%  Get labels
alltrialLabels_target = [repmat({'No-stop'},length(nostopTimes_target),1);...
    repmat({'Non-canceled'},length(noncancTimes_target),1),;...
    repmat({'Canceled'},length(cancTimes_target),1)];
alltrialLabels_saccade = [repmat({'No-stop'},length(nostopTimes_saccade),1);...
    repmat({'Non-canceled'},length(noncancTimes_saccade),1)];

time = [-1000:2000];
histogramPeriod = [-400:50:0];
burstTime_rasterPlot(1,1) = gramm('x',allBurstTimes_target,'color',alltrialLabels_target);
burstTime_rasterPlot(2,1)=gramm('x',time,'y',[betaValues.target.canceled';betaValues.target.nostop';betaValues.target.noncanc'],...
    'color',[repmat({'Canceled'},29,1);repmat({'No-stop'},29,1);repmat({'Non-canceled'},29,1)]); 

burstTime_rasterPlot(1,1).geom_raster('geom','point');
burstTime_rasterPlot(1,1).set_point_options('base_size',1);
burstTime_rasterPlot(2,1).stat_summary()

burstTime_rasterPlot(1,1).no_legend(); burstTime_rasterPlot(2,1).no_legend();
burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot(1,1).axe_property('XLim',[-400 -200]); 
burstTime_rasterPlot(2,1).axe_property('XLim',[-400 -200]); 
burstTime_rasterPlot(2,1).axe_property('YLim',[0.00025 0.002]);
burstTime_rasterPlot.set_color_options('map',[colors.canceled;colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 150 500]);
burstTime_rasterPlot.draw();

%%
time = [-1000:2000];
burstTime_rasterPlot(1,1) = gramm('x',allBurstTimes_saccade,'color',alltrialLabels_saccade);
burstTime_rasterPlot(2,1)=gramm('x',time,'y',[betaValues.saccade.nostop';betaValues.saccade.noncanc'],...
    'color',[repmat({'No-stop'},29,1);repmat({'Non-canceled'},29,1)]); 

burstTime_rasterPlot(1,1).geom_raster('geom','point');
burstTime_rasterPlot(1,1).set_point_options('base_size',1);
burstTime_rasterPlot(2,1).stat_summary()

burstTime_rasterPlot(1,1).no_legend(); burstTime_rasterPlot(2,1).no_legend();
burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot(1,1).axe_property('XLim',[-200 200]); 
burstTime_rasterPlot(2,1).axe_property('XLim',[-200 200]); 
burstTime_rasterPlot(2,1).axe_property('YLim',[0.00025 0.002]);
burstTime_rasterPlot.set_color_options('map',[colors.nostop;colors.noncanc]);

figure('Renderer', 'painters', 'Position', [100 100 150 500]);
burstTime_rasterPlot.draw();