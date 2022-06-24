%% Get beta burst information
for eventType = 3
    eventLabel = eventNames{eventType};
    alignmentParameters.eventN = eventType;
    fprintf(['Analysing data aligned on ' eventLabel '. \n']);
    
    for session = 1:29
        
        clear betaOutput morletLFP
        
        % Get session name (to load in relevant file)
        sessionName = FileNames{session};
        fprintf('...analysing beta-bursts on session number %i of 29. \n',session);
        
        % Load in morlet transformed data
        loadname = ['morletData\eeg_session' int2str(session) '_' sessionName '_morlet_' eventLabel];
        load([outputDir loadname],'filteredLFP','morletLFP')
        
        % Get beta bursts
        parfor medianCutoff = 1:10
            [betaOutput{medianCutoff}] = betaBurstCount(morletLFP, morletParameters, medianCutoff);
        end
        
        
        % Save output
        savename = ['betaBurst\neurometric\eeg_session' int2str(session) '_' sessionName '_betaOutputNeurometric_' eventLabel];
        save([outputDir savename],'betaOutput','-v7.3')
        
        clear betaOutput morletLFP
        
    end
end


%%
for session = 1:29
    
end

%%
close all

for session = 1:29
    
    figure;
    subplot(1,2,1)
    plot(neurometricX(1,:,session),neurometricY(6,:,session),'r')
    hold on
    scatter(inh_pBurstOutSSD{session,6},inh_pBurstOut{session,6},'ro','filled')
    plot(psychometricX(1,:,session),psychometricY(6,:,session),'b')
    scatter(executiveBeh.inh_SSD{session},executiveBeh.inh_pNC{session},'bo','filled')
    
    subplot(1,2,2)
    scatter(psychometricY(6,:,session),neurometricY(6,:,session),'bo','filled')
    
end

clear neurometricCollapse psychometricCollapse
for session  = 1:29
    neurometricCollapse{session} = neurometricY(6,:,session);
    psychometricCollapse{session} = psychometricY(6,:,session);
end


ssdTime = 1:600;

g(1,1)=gramm('x',ssdTime,'y',neurometricCollapse,'color',executiveBeh.nhpSessions.monkeyNameLabel); % Inhibition function
g(1,2)=gramm('x',ssdTime,'y',psychometricCollapse,'color',executiveBeh.nhpSessions.monkeyNameLabel); % Inhibition function

g(1,1).stat_summary();g(1,2).stat_summary()
g(1,1).no_legend(); g(1,2).no_legend();

g(1,1).set_color_options('map',[colors.euler;colors.xena])
g(1,2).set_color_options('map',[colors.euler;colors.xena])
figure('Position',[100 100 450 200]);
g.draw();


%%
clear neuro_psych_metricCorr_R neuro_psych_metricCorr_P
corrWindow = [50:50:400];
for session = 1:29
    for LFPthreshold = 1:10
        [neuro_psych_metricCorr_R(LFPthreshold,session),...
            neuro_psych_metricCorr_P(LFPthreshold,session)] =...
            corr(psychometricY(LFPthreshold,corrWindow,session)',neurometricY(LFPthreshold,corrWindow,session)');
    end
end

metricRvalues = reshape(neuro_psych_metricCorr_R,290,1);
thresholdMatrix = repmat([1:10]',29,1);
monkeyMatrix = [repmat({'Euler'},60,1); repmat({'Xena'},70,1); repmat({'Euler'},60,1); repmat({'Xena'},100,1)];

clear test
test(1,1)= gramm('x',thresholdMatrix,'y',metricRvalues, 'color', monkeyMatrix);

test(1,1).stat_summary();
test(1,1).geom_jitter('alpha',0.5,'dodge',0.75);

test.set_color_options('map',[colors.euler;colors.xena]);
test(1,1).axe_property('YLim',[-1.0 1]);

figure('Renderer', 'painters', 'Position', [100 100 300 250]);
test.draw();






%% pBurst x Threshold

% Short SSD
% Long SSD

clear test
test(1,1)=gramm('x',[[1:10]';[1:10]'],'y',[pBurst_session(:,1);pBurst_session(:,3)],...
    'color',[repmat({'1'},10,1);repmat({'2'},10,1)]);

% Plot SSD x pNC and pBurst
test(1,1).stat_summary()
test(1,1).no_legend()
test(1,1).axe_property('YLim',[0 0.4]);


figure('Position',[100 100 300 250]);
test.draw();

%%
