dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

for session = 1:29
    midSSD = executiveBeh.midSSDindex(session);
    
    ttx.midSSD.canc{session} = executiveBeh.ttm_CGO{session,midSSD}.C_matched;
    ttx.midSSD.nostop{session} = executiveBeh.ttm_CGO{session,midSSD}.GO_matched;
end


clear burstTiming
burstTiming.saccade.noncanc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC,FileNames, bayesianSSRT, [100 300], 'saccade');
burstTiming.saccade.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO,FileNames, bayesianSSRT, [100 300], 'saccade');

burstTiming.stopSignal.canc = SEF_stoppingEEG_getAverageBurstTime_postSSRT(1:29,...
    ttx.midSSD.canc,FileNames, bayesianSSRT, [0 200], 'stopSignal');
burstTiming.stopSignal.nostop = SEF_stoppingEEG_getAverageBurstTime_postSSRT(1:29,...
    ttx.midSSD.nostop,FileNames, bayesianSSRT, [0 200], 'stopSignal');



%% pBurst Bar Chart
noncanc_error_pBurst = burstTiming.saccade.noncanc.pTrials_burst;
nostop_error_pBurst = burstTiming.saccade.nostop.pTrials_burst;

canc_stopping_pBurst = burstTiming.stopSignal.canc.pTrials_burst;
nostop_stopping_pBurst = burstTiming.stopSignal.nostop.pTrials_burst;

groupLabels_error = [repmat({'No-stop'},29,1); repmat({'Non-canceled'},29,1)];
burstData_error = [nostop_error_pBurst; noncanc_error_pBurst];

groupLabels_stopping = [repmat({'No-stop'},29,1); repmat({'Canceled'},29,1)];
burstData_stopping = [nostop_stopping_pBurst; canc_stopping_pBurst];

%% Concatenate across all sessions
noncancTimes_saccade = []; nostopTimes_saccade = [];
cancTimes_stopSignal = []; nostopTimes_stopSignal = [];

for session = 1:29
    noncancTimes_saccade = [noncancTimes_saccade;burstTiming.saccade.noncanc.burstTimes{session}];
    nostopTimes_saccade = [nostopTimes_saccade;burstTiming.saccade.nostop.burstTimes{session}];

    cancTimes_stopSignal = [cancTimes_stopSignal;burstTiming.stopSignal.canc.burstTimes{session}];
    nostopTimes_stopSignal = [nostopTimes_stopSignal;burstTiming.stopSignal.nostop.burstTimes{session}];

end

alltrialLabels_saccade = [repmat({'No-stop'},length(nostopTimes_saccade),1);...
    repmat({'Non-canceled'},length(noncancTimes_saccade),1)];

alltrialLabels_stopSignal = [repmat({'No-stop'},length(nostopTimes_stopSignal),1);...
    repmat({'Canceled'},length(cancTimes_stopSignal),1)];

clear burstTime_rasterPlot
histogramPeriod = [-250:50:500];

%%
% Set data
burstTime_rasterPlot(1,1)= gramm('x',groupLabels_error,'y',burstData_error, 'color',groupLabels_error);
burstTime_rasterPlot(2,1) = gramm('x',[nostopTimes_saccade; noncancTimes_saccade],'color',alltrialLabels_saccade);
burstTime_rasterPlot(3,1) = gramm('x',[nostopTimes_saccade; noncancTimes_saccade],'color',alltrialLabels_saccade);

burstTime_rasterPlot(1,2)= gramm('x',groupLabels_stopping,'y',burstData_stopping, 'color',groupLabels_stopping);
burstTime_rasterPlot(2,2) = gramm('x',[nostopTimes_stopSignal; cancTimes_stopSignal],'color',alltrialLabels_stopSignal);
burstTime_rasterPlot(3,2) = gramm('x',[nostopTimes_stopSignal; cancTimes_stopSignal],'color',alltrialLabels_stopSignal);


% Set figure type
burstTime_rasterPlot(1,1).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
burstTime_rasterPlot(2,1).geom_raster('geom','point');
burstTime_rasterPlot(3,1).stat_bin('edges',histogramPeriod,'geom','line');
burstTime_rasterPlot(1,2).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
burstTime_rasterPlot(2,2).geom_raster('geom','point');
burstTime_rasterPlot(3,2).stat_bin('edges',histogramPeriod,'geom','line');


% Set plot details
burstTime_rasterPlot(2,:).set_point_options('base_size',0.75)
burstTime_rasterPlot(1,1).no_legend(); burstTime_rasterPlot(2,1).no_legend(); burstTime_rasterPlot(3,1).no_legend()
burstTime_rasterPlot(1,2).no_legend(); burstTime_rasterPlot(2,2).no_legend(); burstTime_rasterPlot(3,2).no_legend()
burstTime_rasterPlot.set_names('y','');
burstTime_rasterPlot(:,1).set_color_options('map',[colors.nostop;colors.noncanc]);
burstTime_rasterPlot(:,2).set_color_options('map',[colors.canceled;colors.nostop]);
burstTime_rasterPlot(2,1).axe_property('XLim',[-250 500]); burstTime_rasterPlot(3,1).axe_property('XLim',[-250 500]);
burstTime_rasterPlot(2,2).axe_property('XLim',[-250 500]); burstTime_rasterPlot(3,2).axe_property('XLim',[-250 500]);
burstTime_rasterPlot(1,1).axe_property('YLim',[0 0.3]); burstTime_rasterPlot(1,2).axe_property('YLim',[0 0.3]);
burstTime_rasterPlot(3,1).axe_property('YLim',[0 0.15]); burstTime_rasterPlot(3,2).axe_property('YLim',[0 0.15]);

% Generate figure
figure('Position',[100 100 400 550]);
burstTime_rasterPlot.draw();

