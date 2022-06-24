dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

clear burstTiming

burstTiming.canc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx_canc,FileNames, bayesianSSRT, [-400 -200], 'target');

burstTiming.noncanc = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.NC,FileNames, bayesianSSRT, [-400 -200], 'target');

burstTiming.nostop = SEF_stoppingEEG_getAverageBurstTime(1:29,...
    executiveBeh.ttx.GO,FileNames, bayesianSSRT, [-400 -200], 'target');

%% Set up figure
clear burstParameters_stoppingBeh sessions
% Get input data:
sessions = 1:29
%   Mean burst time and SSRT relationship
burstParameters_stoppingBeh(1,1)=gramm('x',burstTiming.nostop.mean_burstTime(sessions),'y',burstTiming.nostop.mean_ssrt(sessions));
burstParameters_stoppingBeh(1,2)=gramm('x',burstTiming.noncanc.mean_burstTime(sessions),'y',burstTiming.noncanc.mean_ssrt(sessions));
burstParameters_stoppingBeh(1,3)=gramm('x',burstTiming.canc.mean_burstTime(sessions),'y',burstTiming.canc.mean_ssrt(sessions));
%   STD burst time and SSRT relationship
burstParameters_stoppingBeh(2,1)=gramm('x',burstTiming.nostop.std_burstTime(sessions),'y',burstTiming.nostop.std_ssrt(sessions));
burstParameters_stoppingBeh(2,2)=gramm('x',burstTiming.noncanc.std_burstTime(sessions),'y',burstTiming.noncanc.std_ssrt(sessions));
burstParameters_stoppingBeh(2,3)=gramm('x',burstTiming.canc.std_burstTime(sessions),'y',burstTiming.canc.std_ssrt(sessions));
%   Mean burst time and trigger failures
burstParameters_stoppingBeh(3,1)=gramm('x',burstTiming.nostop.mean_burstTime(sessions),'y',burstTiming.nostop.triggerFailures(sessions));
burstParameters_stoppingBeh(3,2)=gramm('x',burstTiming.noncanc.mean_burstTime(sessions),'y',burstTiming.noncanc.triggerFailures(sessions));
burstParameters_stoppingBeh(3,3)=gramm('x',burstTiming.canc.mean_burstTime(sessions),'y',burstTiming.canc.triggerFailures(sessions));
%   p(Burst) and trigger failures
burstParameters_stoppingBeh(4,1)=gramm('x',burstTiming.nostop.pTrials_burst(sessions),'y',burstTiming.nostop.triggerFailures(sessions));
burstParameters_stoppingBeh(4,2)=gramm('x',burstTiming.noncanc.pTrials_burst(sessions),'y',burstTiming.noncanc.triggerFailures(sessions));
burstParameters_stoppingBeh(4,3)=gramm('x',burstTiming.canc.pTrials_burst(sessions),'y',burstTiming.canc.triggerFailures(sessions));

alphaLevel = 0.7;
%Generalized linear model fit
burstParameters_stoppingBeh(1,1).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(1,1).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(1,1).geom_abline(); burstParameters_stoppingBeh(1,1).set_color_options('map',colors.nostop);
burstParameters_stoppingBeh(1,2).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(1,2).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(1,2).geom_abline(); burstParameters_stoppingBeh(1,2).set_color_options('map',colors.noncanc);
burstParameters_stoppingBeh(1,3).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(1,3).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(1,3).geom_abline(); burstParameters_stoppingBeh(1,3).set_color_options('map',colors.canceled);

burstParameters_stoppingBeh(2,1).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(2,1).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(2,1).geom_abline(); burstParameters_stoppingBeh(2,1).set_color_options('map',colors.nostop);
burstParameters_stoppingBeh(2,2).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(2,2).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(2,2).geom_abline(); burstParameters_stoppingBeh(2,2).set_color_options('map',colors.noncanc);
burstParameters_stoppingBeh(2,3).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(2,3).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(2,3).geom_abline(); burstParameters_stoppingBeh(2,3).set_color_options('map',colors.canceled);

burstParameters_stoppingBeh(3,1).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(3,1).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(3,1).set_color_options('map',colors.nostop);
burstParameters_stoppingBeh(3,2).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(3,2).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(3,2).set_color_options('map',colors.noncanc);
burstParameters_stoppingBeh(3,3).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(3,3).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(3,3).set_color_options('map',colors.canceled);

burstParameters_stoppingBeh(4,1).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(4,1).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(4,1).geom_abline(); burstParameters_stoppingBeh(4,1).set_color_options('map',colors.nostop);
burstParameters_stoppingBeh(4,2).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(4,2).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(4,2).geom_abline(); burstParameters_stoppingBeh(4,2).set_color_options('map',colors.noncanc);
burstParameters_stoppingBeh(4,3).geom_point('alpha',alphaLevel); burstParameters_stoppingBeh(4,3).stat_glm('fullrange',true,'disp_fit',true); burstParameters_stoppingBeh(4,3).geom_abline(); burstParameters_stoppingBeh(4,3).set_color_options('map',colors.canceled);
% 
% burstParameters_stoppingBeh(1,:).axe_property('XLim',[0 200]); burstParameters_stoppingBeh(1,:).axe_property('YLim',[0 200]);
% burstParameters_stoppingBeh(2,:).axe_property('XLim',[0 80]); burstParameters_stoppingBeh(2,:).axe_property('YLim',[0 80]);
% burstParameters_stoppingBeh(3,:).axe_property('XLim',[0 100]); burstParameters_stoppingBeh(3,:).axe_property('YLim',[-0.05 0.3]);
% burstParameters_stoppingBeh(4,:).axe_property('XLim',[-0.05 0.3]); burstParameters_stoppingBeh(4,:).axe_property('YLim',[-0.05 0.3]);

burstParameters_stoppingBeh(1,:).set_names('x','Mean beta-burst time (ms)','y','Mean SSRT (ms)');
burstParameters_stoppingBeh(2,:).set_names('x','SD beta-burst time (ms)','y','SD SSRT (ms)');
burstParameters_stoppingBeh(3,:).set_names('x','Mean beta-burst time (ms)','y','P(Trigger Failures)');
burstParameters_stoppingBeh(4,:).set_names('x','p(trials with burst)','y','P(Trigger Failures)');

figure('Renderer', 'painters', 'Position', [100 100 500 700]);
burstParameters_stoppingBeh.draw();


%%

testA = burstTiming.canc.std_burstTime
testB = burstTiming.canc.std_ssrt

testTable = table(testA,testB)
writetable(testTable,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\test.csv','WriteRowNames',true)


