for session = 1:29
    midSSD = executiveBeh.midSSDarray(session,:);
    
    ttxStoppingSSD.C.early{session} = executiveBeh.ttm_c.C{session, midSSD(1)}.all;
    ttxStoppingSSD.C.mid{session} = executiveBeh.ttm_c.C{session, midSSD(2)}.all;
    ttxStoppingSSD.C.late{session} = executiveBeh.ttm_c.C{session, midSSD(3)}.all;
    
    ttxStoppingSSD.GO.early{session} = executiveBeh.ttm_c.GO_C{session, midSSD(1)}.all;
    ttxStoppingSSD.GO.mid{session} = executiveBeh.ttm_c.GO_C{session, midSSD(2)}.all;
    ttxStoppingSSD.GO.late{session} = executiveBeh.ttm_c.GO_C{session, midSSD(3)}.all;
end



window = [100 300];

% Get beta burst details (proportion, timing, etc...) aligned on saccade
% for non-canceled and no-stop trials
clear stoppingBetaBurst noncanc_stopping_pBurst nostop_stopping_pBurst stoppingRTtable

stoppingBetaBurst.C.early = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxStoppingSSD.C.early,FileNames, bayesianSSRT);
stoppingBetaBurst.C.mid = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxStoppingSSD.C.mid,FileNames, bayesianSSRT);
stoppingBetaBurst.C.late = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxStoppingSSD.C.late,FileNames, bayesianSSRT);

stoppingBetaBurst.GO.early = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxStoppingSSD.GO.early,FileNames, bayesianSSRT);
stoppingBetaBurst.GO.mid = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxStoppingSSD.GO.mid,FileNames, bayesianSSRT);
stoppingBetaBurst.GO.late = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    ttxStoppingSSD.GO.late,FileNames, bayesianSSRT);

clear pBurst_stoppingSSD groupLabels epochLabels burstData

labels = [repmat({'Early'},29,1);repmat({'Mid'},29,1);repmat({'Late'},29,1)];
data = [stoppingBetaBurst.C.early.pTrials_burst;...
    stoppingBetaBurst.C.mid.pTrials_burst;...
    stoppingBetaBurst.C.late.pTrials_burst] - ...
    [stoppingBetaBurst.GO.early.pTrials_burst;...
    stoppingBetaBurst.GO.mid.pTrials_burst;...
    stoppingBetaBurst.GO.late.pTrials_burst];

pBurst_stoppingSSD(1,1)= gramm('x',labels,'y',data,'color',labels);

pBurst_stoppingSSD(1,1).stat_boxplot();
pBurst_stoppingSSD(1,1).geom_jitter('alpha',0.5,'dodge',0.75);

pBurst_stoppingSSD.set_color_options('map','d3.schemePaired');

figure('Renderer', 'painters', 'Position', [100 100 400 300]);
pBurst_stoppingSSD.draw();


%% Export data for stats in JASP
session = [1:29]'; monkey = executiveBeh.nhpSessions.monkeyNameLabel;
earlyBurst = stoppingBetaBurst.C.early.pTrials_burst - stoppingBetaBurst.GO.early.pTrials_burst;
midBurst = stoppingBetaBurst.C.mid.pTrials_burst - stoppingBetaBurst.GO.mid.pTrials_burst;
lateBurst = stoppingBetaBurst.C.late.pTrials_burst - stoppingBetaBurst.GO.late.pTrials_burst;

stoppingSSD_BetaBurstData = table(session, monkey, earlyBurst, midBurst,lateBurst);

writetable(stoppingSSD_BetaBurstData,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_pBurst_stoppingSSD.csv','WriteRowNames',true)



