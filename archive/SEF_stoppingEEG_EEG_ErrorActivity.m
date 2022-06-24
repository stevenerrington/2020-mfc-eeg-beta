window = [100 300];

% Get beta burst details (proportion, timing, etc...) aligned on saccade
% for non-canceled and no-stop trials
clear errorBetaBurst noncanc_error_pBurst nostop_error_pBurst errorRTtable

errorBetaBurst.noncanc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC,FileNames, bayesianSSRT, window, 'saccade');
errorBetaBurst.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO,FileNames, bayesianSSRT, window, 'saccade');

noncanc_error_pBurst = errorBetaBurst.noncanc.pTrials_burst;
nostop_error_pBurst = errorBetaBurst.nostop.pTrials_burst;

errorRTtable = table();
for session = 1:29
    errorRTtable.mean_ncRT(session,1) = nanmean(executiveBeh.RTdata.RTinfo.all{session}.ncRT.dist);
    errorRTtable.std_ncRT(session,1) = nanstd(executiveBeh.RTdata.RTinfo.all{session}.ncRT.dist);
    
    errorRTtable.mean_goRT(session,1) = nanmean(executiveBeh.RTdata.RTinfo.all{session}.goRT.dist);
    errorRTtable.std_goRT(session,1) = nanstd(executiveBeh.RTdata.RTinfo.all{session}.goRT.dist);        
end


%% Relevant figure
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pBurst x trial type
% Get the labels, data arranged appropriately
groupLabels = [repmat({'No-stop'},29,1); repmat({'Non-canceled'},29,1)];
epochLabels = [repmat({'post-SSRT'},29*2,1)];
burstData = [errorBetaBurst.nostop.pTrials_burst; errorBetaBurst.noncanc.pTrials_burst];

% Set up gramm
clear pBurst_trialType
error_pBurst_trialType(1,1)= gramm('x',groupLabels,'y',burstData,'color',epochLabels);

% Bar Chart
error_pBurst_trialType(1,1).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
error_pBurst_trialType(1,1).set_color_options('map','d3.schemePaired')
error_pBurst_trialType.set_names('x','Trial Type','y','p (burst | trial)');
% error_pBurst_trialType.axe_property('YLim',[0 0.15]);

% Draw!
figure('Position',[100 100 200 150]);
error_pBurst_trialType.draw();


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear error_pBurst_RT
error_pBurst_RT(1,1)= gramm('x',errorBetaBurst.nostop.pTrials_burst,'y',errorRTtable.mean_goRT);
error_pBurst_RT(1,2)= gramm('x',errorBetaBurst.noncanc.pTrials_burst,'y',errorRTtable.mean_ncRT);

error_pBurst_RT(1,1).geom_point('alpha',0.5); error_pBurst_RT(1,2).geom_point('alpha',0.5);
error_pBurst_RT(1,1).stat_glm('fullrange',true,'disp_fit',true); error_pBurst_RT(1,2).stat_glm('fullrange',true,'disp_fit',true);
error_pBurst_RT(1,1).set_color_options('map',colors.nostop);error_pBurst_RT(1,2).set_color_options('map',colors.noncanc);

figure('Renderer', 'painters', 'Position', [100 100 500 200]);
error_pBurst_RT.draw();


%% Export data for stats in JASP
session = [1:29]'; monkey = executiveBeh.nhpSessions.monkeyNameLabel;
errorBetaBurstData = table(session, monkey, noncanc_error_pBurst,nostop_error_pBurst);

writetable(errorBetaBurstData,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_pBurst_error.csv','WriteRowNames',true)