% Post SSRT period on canceled trials
dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

clear beta_cancBaseline beta_nostopBaseline beta_noncancBaseline

baselineWin = [-400 -200];

for session = 1:29
    clear betaOutput  trials_nc trials_c trials_ns...
         trial_noncanc_betaBurstFlag trial_canceled_betaBurstFlag trial_nostop_betaBurstFlag
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    postSSRTwindow = [bayesianSSRT.ssrt_mean(session)+50 bayesianSSRT.ssrt_mean(session)+250];
    
    % Load in beta output data for session
    loadFile = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_stopSignal'];
    load([dataDir loadFile]);
        
    trials_nc = executiveBeh.Trials.all{session}.t_GO_after_NC;
    trials_c = executiveBeh.Trials.all{session}.t_GO_after_C;
    trials_ns = executiveBeh.Trials.all{session}.t_GO_after_GO;
    
    for trlIdx = 1:length(trials_nc)
        trl = trials_nc(trlIdx);
        trial_noncanc_betaBurstFlag(trlIdx,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= baselineWin(1) &...
           betaOutput.burstData.burstTime{trl} <= baselineWin(2)));
    end
    
    for trlIdx = 1:length(trials_c)
        trl = trials_c(trlIdx);
        trial_canceled_betaBurstFlag(trlIdx,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= baselineWin(1) &...
           betaOutput.burstData.burstTime{trl} <= baselineWin(2)));
    end    
    
    for trlIdx = 1:length(trials_ns)
        trl = trials_ns(trlIdx);
        trial_nostop_betaBurstFlag(trlIdx,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= baselineWin(1) &...
           betaOutput.burstData.burstTime{trl} <= baselineWin(2)));
    end    
    
    beta_cancBaseline(session,1) = mean(trial_canceled_betaBurstFlag);
    beta_nostopBaseline(session,1) = mean(trial_nostop_betaBurstFlag);
    beta_noncancBaseline(session,1) = mean(trial_noncanc_betaBurstFlag);
end


[mean(beta_cancBaseline), std(beta_cancBaseline)]*100
[mean(beta_nostopBaseline), std(beta_nostopBaseline)]*100
[mean(beta_noncancBaseline), std(beta_noncancBaseline)]*100


%% /////////////////////////////////////////////

labels = [repmat({'Canceled'}, 29,1);repmat({'No-Stop'}, 29,1);repmat({'Non-Canceled'}, 29,1)];
g(1,1)=gramm('x',labels,'y',[beta_cancBaseline; beta_nostopBaseline; beta_noncancBaseline],'color',labels);
g(1,1).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
g.set_names('x','Trial Type','y','p (burst | trial)');
figure('Position',[100 100 300 200]);
g.draw();

%% Export data for stats in JASP
session = [1:29]'; monkey = executiveBeh.nhpSessions.monkeyNameLabel;
trialHistory_BetaBurstData = table(session, monkey, beta_cancBaseline,beta_nostopBaseline,beta_noncancBaseline);

writetable(trialHistory_BetaBurstData,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\workingFolder\exportJASP\EEG_pBurst_trialHistoryBaseline.csv','WriteRowNames',true)