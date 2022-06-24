%
%% pBurst x median threshold
% Extract beta-burst information across multiple thresholds.

alignmentParameters.eventN = 3;
eventLabel = eventNames{alignmentParameters.eventN};
fprintf(['Analysing data aligned on ' eventLabel '. \n']);

for session = 1:29

    clear betaOutput morletLFP

    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('...analysing beta-bursts on session number %i of 29. \n',session);

    % Load in morlet transformed data
    loadname = ['morletData\eeg_session' int2str(session) '_' sessionName '_morlet_' eventLabel];
    load([outputDir loadname],'filteredLFP','morletLFP')

    % Get beta bursts at multiple threshold cutoffs
    parfor medianCutoff = 1:10
        [betaOutput{medianCutoff}] = betaBurstCount(morletLFP, morletParameters, medianCutoff);
    end


    % Save output
    savename = ['betaBurst\neurometric\eeg_session' int2str(session) '_' sessionName '_betaOutputNeurometric_' eventLabel];
    save([outputDir savename],'betaOutput','-v7.3')

    clear betaOutput morletLFP

end

%% Examine proportion of beta-bursts observed across

for session = 1:29
    
    % Find number of trials at each SSD for each session
    for ssdIdx = 1:length(executiveBeh.inh_SSD{session})
        nTrls(session,ssdIdx) = length(executiveBeh.ttm_CGO{session,ssdIdx}.C_unmatched);
    end
    
    % Get session name
    sessionName = FileNames{session};
    % ...and load session data
    clear betaOutput
    loadname = ['betaBurst\neurometric\eeg_session' int2str(session) '_' sessionName '_betaOutputNeurometric_stopSignal'];
    load([outputDir loadname]); fprintf('Analysing p(beta-bursts) on session number %i of 29. \n',session);
    
    % Get behavioral values
    clear validSSDidx validSSDvalue validpNCvalue validnTrvalue nSSDs
    validSSDidx = find(nTrls(session,:) >= 1);
    validSSDvalue = executiveBeh.inh_SSD{session}(validSSDidx);
    validpNCvalue = 1-executiveBeh.inh_pNC{session}(validSSDidx);
    validnTrvalue = executiveBeh.inh_trcount_SSD{session}(validSSDidx);
    nSSDs = length(validSSDvalue);
    
    % THEN, for each threshold & at each SSD
  
    
end

%% Fit Weibull
for session = 1:29
    fprintf('Fitting Weibull for session number %i of 29. \n',session);
    for LFPthreshold = 1:10
        % Fit Weibull function for SSD x pBurst(Neurometric)
        [~,~,neurometric.X(LFPthreshold,:,session),neurometric.Y(LFPthreshold,:,session)] =...
            SEF_LFPToolbox_FitWeibull...
            (inh_pBurstOut.SSD{session,LFPthreshold},...
            inh_pBurstOut.pBurst{session,LFPthreshold},...
            inh_pBurstOut.nTr{session,LFPthreshold});
        
        % Fit Weibull function for SSD x pRespond (Psychometric)
        [~,~,psychometric.X(LFPthreshold,:,session),psychometric.Y(LFPthreshold,:,session)] =...
            SEF_LFPToolbox_FitWeibull...
            (inh_pBurstOut.SSD{session,LFPthreshold},...
            inh_pBurstOut.PNC{session,LFPthreshold},...
            inh_pBurstOut.nTr{session,LFPthreshold});
    end
end


%% Look at & assess weibull fits

close all
corrTimes = [25:25:300]; threshold = 6; figFlag = 1;
for session = 1:29
    if figFlag
        figure('Renderer', 'painters', 'Position', [100 100 600 250]);
        subplot(1,2,1)
        plot(psychometric.X(threshold,:,session),psychometric.Y(threshold,:,session),'r')
        hold on;
        scatter(inh_pBurstOut.SSD{session,threshold},inh_pBurstOut.PNC{session,threshold},'ro','filled')
        plot(psychometric.X(threshold,:,session),neurometric.Y(threshold,:,session),'b')
        scatter(inh_pBurstOut.SSD{session,threshold},inh_pBurstOut.pBurst{session,threshold},'bo','filled')
        ylim([0 1]);
        
        subplot(1,2,2)
        scatter(psychometric.Y(threshold,corrTimes,session),neurometric.Y(threshold,corrTimes,session),'k','filled')
        xlim([0 1]); ylim([0 1]);
        xlabel('Psychometric'); ylabel('Neurometric')
    end
    
    [r(session,1),p(session,1)] = corr(psychometric.Y(threshold,corrTimes,session)',neurometric.Y(threshold,corrTimes,session)');
    
    clear slopeFit
    slopeFit = polyfit(psychometric.Y(threshold,corrTimes,session)',neurometric.Y(threshold,corrTimes,session)',1) ;
    slope(session,1) = slopeFit(2);
    
    clear mdl
    mdl = GeneralizedLinearModel.fit...
        (psychometric.Y(threshold,corrTimes,session)',...
        neurometric.Y(threshold,corrTimes,session)',...
        'Distribution','Normal');
    
    slope_GLM(session,:) = [mdl.Coefficients.Estimate(2), mdl.Coefficients.pValue(2)];
end

if figFlag
    figure; histogram(slope_GLM(:,1))
end


%% Compare values at each point

for session = 1:29
    for LFPthreshold = 1:10
        diffTest_burstRaw {session,LFPthreshold} = ...
            inh_pBurstOut.PNC{session,LFPthreshold}-...
            inh_pBurstOut.pBurst{session,LFPthreshold};
        
        diffTest_burstNorm {session,LFPthreshold} = ...
            inh_pBurstOut.PNC{session,LFPthreshold}-...
            inh_pBurstOut.pBurst{session,LFPthreshold}./...
            max(inh_pBurstOut.pBurst{session,LFPthreshold});
        
        testRaw(session,LFPthreshold) = sum(diffTest_burstRaw{session,LFPthreshold}.^2);
        testNorm(session,LFPthreshold) = sum(diffTest_burstNorm{session,LFPthreshold}.^2);

        testRawMean(session,LFPthreshold) = mean(diffTest_burstRaw{session,LFPthreshold});
        
    end
end

for LFPthreshold = 1:10
    [ttest_raw(LFPthreshold,1), ttest_raw_p(LFPthreshold,1), ~, ttest_raw_stats{LFPthreshold,1}] = ttest(testRaw(:,LFPthreshold));
    ttest_norm(LFPthreshold,1) = ttest(testNorm(:,LFPthreshold));
    ttest_normMean(LFPthreshold,1) = ttest(testRawMean(:,LFPthreshold));
end


[h,p,~,stats] = ttest(testRaw(:,6));

mean(testRaw)
mean(testNorm)

figure;
plot(nanmean(testRaw))

hold on
plot(nanmean(testNorm))

sumsquaredDiff = testRaw(:,6);
sumsquaredDiff = table(sumsquaredDiff);
writetable(sumsquaredDiff,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_sumsquaredDiff.csv','WriteRowNames',true)

output_threshold_sumSquareDiff = table();
output_threshold_sumSquareDiff.sumSquareDiff = reshape(testRaw,290,1);
output_threshold_sumSquareDiff.threshold = repmat([1:10]',29,1);

writetable(output_threshold_sumSquareDiff,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_sumsquaredDiff_Threshold.csv','WriteRowNames',true)


%% Get neurometric and psychometric functions collapsed acrossed sessions
%  at study used 6x median threshold

clear neurometricCollapse psychometricCollapse
for session  = 1:29
    neurometricCollapse{session} = neurometric.Y(6,:,session);
    psychometricCollapse{session} = psychometric.Y(6,:,session);
end

clear neurometricAverage psychometricAverage
for session = 1:29
    neurometricAverage(session,:) = neurometric.Y(6,:,session);
    psychometricAverage(session,:) = psychometric.Y(6,:,session);
end

neurometricAverage = mean(neurometricAverage);
psychometricAverage = mean(psychometricAverage);

ssdTime = 1:600;

%% Get neuro/psychometric correlation
corrTimes = [25:25:300];
clear slope_GLM_slope slope_GLM_p slope_GLM_slope_histData slope_GLM_p_histData
for session = 1:29
    for threshold = 1:10
        clear mdl
        
        % Fit GLM between neurometric Y and psychometric Y at given
        % timepoints
        mdl = GeneralizedLinearModel.fit...
            (psychometric.Y(threshold,corrTimes,session)',...
            neurometric.Y(threshold,corrTimes,session)',...
            'Distribution','Normal');
        
        slope_GLM_slope{session}(threshold) = [mdl.Coefficients.Estimate(2)];
        slope_GLM_p{session}(threshold) = mdl.Coefficients.pValue(2);
        
        slope_GLM_slope_histData(threshold,session) = mdl.Coefficients.Estimate(2);
        slope_GLM_p_histData(threshold,session) = mdl.Coefficients.pValue(2);
    end
end

%% Get proportion of bursts observed at each threshold
clear pBurst_Threshold
for session = 1:29
    for LFPthreshold = 1:10
        ssdList = (find(ismember(executiveBeh.inh_SSD{session}...
            (executiveBeh.midSSDarray(session,:)),...
            inh_pBurstOut.SSD{session,LFPthreshold})));
                
        pBurst_Threshold{session}(LFPthreshold,:) =...
            inh_pBurstOut.pBurst{session, LFPthreshold}(ssdList);
    end
end

clear pBurst_Threshold_sessionCollapsed
pBurst_Threshold_sessionCollapsed = [];
for session = 1:29
    pBurst_Threshold_sessionCollapsed= [pBurst_Threshold_sessionCollapsed; ...
        pBurst_Threshold{session}, repmat(session,10,1), repmat([1:10]',1,1)];
end

pBurst_Threshold_sessionAveraged = mean(pBurst_Threshold_sessionCollapsed,3);
earlySSD_pBurst = pBurst_Threshold_sessionAveraged(:,1);
midSSD_pBurst = pBurst_Threshold_sessionAveraged(:,2);
lateSSD_pBurst = pBurst_Threshold_sessionAveraged(:,3);
session = pBurst_Threshold_sessionAveraged(:,4);
threshold = pBurst_Threshold_sessionAveraged(:,5);


pBurst_Threshold_JASPtable = table(session, threshold, earlySSD_pBurst,midSSD_pBurst,lateSSD_pBurst);
writetable(pBurst_Threshold_JASPtable,...
    'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_pBurst_Threshold.csv','WriteRowNames',true)


clear pBurst_Threshold_SSD
count = 0;
for session = 1:29
    for ssdIdx = 1:3
        count = count+1;
                
        pBurst_Threshold_SSD{count,1} = pBurst_Threshold{session}(:,ssdIdx)';
        
    end
end

%%
slope_threshold_session = [];

for session = 1:29
        slope_threshold_session =...
            [slope_threshold_session; slope_GLM_slope{session}', [1:10]', repmat(session,10,1)];
end

slope_JASP = slope_threshold_session(:,1);
threshold_JASP = slope_threshold_session(:,2);
session_JASP = slope_threshold_session(:,3);

slopeJASPtable = table(slope_JASP,threshold_JASP,session_JASP);
writetable(slopeJASPtable,...
    'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\workingFolder\exportJASP\EEG_neurometricSlope.csv','WriteRowNames',true)

%% Create figure
clear neurometricFigure

% pBurst x Threshold
neurometricFigure(1,1)=gramm('x',[1:10],...
    'y',pBurst_Threshold_SSD,...
    'color',repmat({'A.Early';'B.Mid';'C.Late'}, 29,1));

% Neurometric and psychometric function
neurometricFigure(1,3)=gramm('x',slope_GLM_slope_histData(6,:));

% Neurometric and psychometric function
neurometricFigure(2,1)=gramm('x',ssdTime,'y',[neurometricCollapse'; psychometricCollapse'],...
    'color', [repmat({'Neurometric'},29,1); repmat({'Psychometric'},29,1)]);

% Neurometric, psychometric correlation
neurometricFigure(2,2)=gramm('x',psychometricAverage(corrTimes)',...
    'y',neurometricAverage(corrTimes)');

% Neurometric, psychometric correlation
neurometricFigure(2,3)=gramm('x',[1:10],'y',slope_GLM_slope);

% Set figure types
neurometricFigure(1,1).stat_summary()
neurometricFigure(1,3).stat_bin('edges',[-1:0.01:1])
neurometricFigure(2,1).stat_summary();neurometricFigure(2,1).geom_vline('xintercept',corrTimes)
neurometricFigure(2,2).geom_point();neurometricFigure(2,2).geom_line();
neurometricFigure(2,3).stat_summary('geom',{'black_errorbar','edge_bar'});

% Set figure parameters
neurometricFigure(1,2).no_legend();
neurometricFigure(1,3).axe_property('XLim',[-0.1 0.1]);neurometricFigure(1,3).axe_property('YLim',[0 30]);
neurometricFigure(2,1).no_legend(); neurometricFigure(2,3).no_legend();
neurometricFigure(2,2).axe_property('XLim',[0 1]);neurometricFigure(2,1).axe_property('YLim',[0 1]);
neurometricFigure(2,2).axe_property('XLim',[0 1]);neurometricFigure(2,2).axe_property('YLim',[0 1]);
neurometricFigure(2,3).axe_property('YLim',[0 0.1]);

neurometricFigure(1,3).set_names('x','Metric slope','y','Frequency');
neurometricFigure(2,1).set_names('x','Stop-signal delay (ms)','y','p (respond | stop-signal)');
neurometricFigure(2,2).set_names('x','Psychometric value','y','Neurometric value');
neurometricFigure(2,3).set_names('x','Burst threshold','y','Function slope');

% Generate figure
figure('Position',[100 100 750 450]);
neurometricFigure.draw();

%%



%% Revise histogram

% Histogram
revised2NeurometricFigure(1,1)=gramm('x',[testRaw(:,2); testRaw(:,6); testRaw(:,10)],'color',[repmat({'2'},29,1); repmat({'6'},29,1); repmat({'10'},29,1)]);
revised2NeurometricFigure(1,1).stat_bin('edges',[-1:0.5:5], 'geom','overlaid_bar')
revised2NeurometricFigure(1,1).geom_vline('xintercept',mean(testRaw(:,2)))
revised2NeurometricFigure(1,1).geom_vline('xintercept',mean(testRaw(:,6)))
revised2NeurometricFigure(1,1).geom_vline('xintercept',mean(testRaw(:,10)))


figure('Position',[100 100 300 250]);
revised2NeurometricFigure.draw();




clear thresholdValues thresholdLabels
thresholdValues = reshape(testRaw,290,1);
thresholdLabels = reshape(repmat([1:10],29,1),290,1);
clear revised2NeurometricFigure
revised2NeurometricFigure(1,1)=gramm('x',...
    thresholdLabels,'y',thresholdValues);

revised2NeurometricFigure(1,1).stat_boxplot()
revised2NeurometricFigure(1,1).axe_property('YLim',[-1.5 5]);
revised2NeurometricFigure(1,1).geom_hline('yintercept',0)

figure('Position',[100 100 300 250]);
revised2NeurometricFigure.coord_flip();
revised2NeurometricFigure.draw();

% X = Vlaues
% Y = Threshold














