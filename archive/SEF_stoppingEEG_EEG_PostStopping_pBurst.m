% Post SSRT period on canceled trials
dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

clear beta_cancSSRT beta_nostopSSRT

for session = 1:29
    clear betaOutput trial_canc trial_nostop...
        trial_nostop_betaBurstFlag trial_canc_betaBurstFlag
    
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    postSSRTwindow = [bayesianSSRT.ssrt_mean(session)+50 bayesianSSRT.ssrt_mean(session)+250];
    
    % Load in beta output data for session
    loadFile = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput_stopSignal'];
    load([dataDir loadFile]) 
    
    midSSD = executiveBeh.midSSDindex(session);
    
    trial_canc = executiveBeh.ttm_CGO{session,midSSD}.C_matched;
    trial_nostop = executiveBeh.ttm_CGO{session,midSSD}.GO_matched;
    
    
    for trlIdx = 1:length(trial_canc)
        trl = trial_canc(trlIdx);
        trial_canc_betaBurstFlag(trlIdx,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= postSSRTwindow(1) &...
            betaOutput.burstData.burstTime{trl} <= postSSRTwindow(2)));
    end
    
    for trlIdx = 1:length(trial_nostop)
        trl = trial_nostop(trlIdx);
        trial_nostop_betaBurstFlag(trl,:) = ~isempty(find(betaOutput.burstData.burstTime{trl} >= postSSRTwindow(1) &...
            betaOutput.burstData.burstTime{trl} <= postSSRTwindow(2)));       
    end
    
    beta_cancSSRT(session,1) = mean(trial_canc_betaBurstFlag);
    beta_nostopSSRT(session,1) = mean(trial_nostop_betaBurstFlag);
end

[mean(beta_cancSSRT), std(beta_cancSSRT)]*100
[mean(beta_nostopSSRT), std(beta_nostopSSRT)]*100


%% /////////////////////////////////////////////

labels = [repmat({'Canceled'}, 29,1);repmat({'No-Stop'}, 29,1)];
g(1,1)=gramm('x',labels,'y',[beta_cancSSRT; beta_nostopSSRT]);
g(1,1).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
g.set_names('x','Trial Type','y','p (burst | trial)');
figure('Position',[100 100 300 200]);
g.draw();

%% Export data for stats in JASP
session = [1:29]'; monkey = executiveBeh.nhpSessions.monkeyNameLabel;
postSSRT_BetaBurstData = table(session, monkey, beta_cancSSRT,beta_nostopSSRT);

writetable(postSSRT_BetaBurstData,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_pBurst_postSSRT.csv','WriteRowNames',true)


%%

for session = 1:29
    
    clear RT
    RT = executiveBeh.TrialEventTimes_Overall{session}(:,4)-...
        executiveBeh.TrialEventTimes_Overall{session}(:,2);
    
    postC_slowIndex(session,1) = mean(RT(executiveBeh.Trials.all{session}.t_GO_after_C))./...
         mean(RT(executiveBeh.Trials.all{session}.t_GO_after_GO));
end

g(1,1)=gramm('x',beta_cancSSRT,'y',postC_slowIndex);
g(1,1).geom_point();
g(1,1).stat_glm('fullrange',true,'disp_fit',true);
g.set_names('x','p (burst | trial)','y','RT slowing index');
figure('Position',[100 100 300 275]);
g.draw();















