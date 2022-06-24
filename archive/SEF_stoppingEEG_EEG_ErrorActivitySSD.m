for session = 1:29
    midSSD = executiveBeh.midSSDarray(session,:);
    ttxErrorSSD.NC.early{session} = executiveBeh.ttm_c.NC{session, midSSD(1)}.all;
    ttxErrorSSD.NC.mid{session} = executiveBeh.ttm_c.NC{session, midSSD(2)}.all;
    ttxErrorSSD.NC.late{session} = executiveBeh.ttm_c.NC{session, midSSD(3)}.all;
    
    ttxErrorSSD.GO.early{session} = executiveBeh.ttm_c.GO_NC{session, midSSD(1)}.all;
    ttxErrorSSD.GO.mid{session} = executiveBeh.ttm_c.GO_NC{session, midSSD(2)}.all;
    ttxErrorSSD.GO.late{session} = executiveBeh.ttm_c.GO_NC{session, midSSD(3)}.all;    
end

window = [100 300];

% Get beta burst details (proportion, timing, etc...) aligned on saccade
% for non-canceled and no-stop trials
clear errorBetaBurst noncanc_error_pBurst nostop_error_pBurst errorRTtable

errorBetaBurst.NC.early = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxErrorSSD.NC.early,FileNames, bayesianSSRT, window, 'saccade');
errorBetaBurst.NC.mid = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxErrorSSD.NC.mid,FileNames, bayesianSSRT, window, 'saccade');
errorBetaBurst.NC.late = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxErrorSSD.NC.late,FileNames, bayesianSSRT, window, 'saccade');

errorBetaBurst.GO.early = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxErrorSSD.GO.early,FileNames, bayesianSSRT, window, 'saccade');
errorBetaBurst.GO.mid = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxErrorSSD.GO.mid,FileNames, bayesianSSRT, window, 'saccade');
errorBetaBurst.GO.late = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxErrorSSD.GO.late,FileNames, bayesianSSRT, window, 'saccade');
%%
clear pBurst_errorSSD groupLabels epochLabels burstData

labels = [repmat({'Early'},29,1);repmat({'Mid'},29,1);repmat({'Late'},29,1)];
data = [errorBetaBurst.NC.early.pTrials_burst;...
    errorBetaBurst.NC.mid.pTrials_burst;...
    errorBetaBurst.NC.late.pTrials_burst] - ...
    [errorBetaBurst.GO.early.pTrials_burst;...
    errorBetaBurst.GO.mid.pTrials_burst;...
    errorBetaBurst.GO.late.pTrials_burst];

pBurst_errorSSD(1,1)= gramm('x',labels,'y',data,'color',labels);

pBurst_errorSSD(1,1).stat_boxplot();
pBurst_errorSSD(1,1).geom_jitter('alpha',0.5,'dodge',0.75);

pBurst_errorSSD.set_color_options('map','d3.schemePaired');

figure('Renderer', 'painters', 'Position', [100 100 400 300]);
pBurst_errorSSD.draw();


%% Export data for stats in JASP
session = [1:29]'; monkey = executiveBeh.nhpSessions.monkeyNameLabel;
earlyBurst = errorBetaBurst.NC.early.pTrials_burst - errorBetaBurst.GO.early.pTrials_burst;
midBurst = errorBetaBurst.NC.mid.pTrials_burst - errorBetaBurst.GO.mid.pTrials_burst;
lateBurst = errorBetaBurst.NC.late.pTrials_burst - errorBetaBurst.GO.late.pTrials_burst;

errorSSD_BetaBurstData = table(session, monkey, earlyBurst, midBurst,lateBurst);

writetable(errorSSD_BetaBurstData,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_pBurst_errorSSD.csv','WriteRowNames',true)
