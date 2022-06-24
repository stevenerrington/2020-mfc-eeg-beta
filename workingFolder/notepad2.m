matDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\behavior\';
dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\pBurst\';
load([matDir 'bayesianSSRT']); load([matDir 'executiveBeh']); load([matDir 'FileNames'])


%% Calculate proportion of trials with burst
pBurstData = table();

for session = 1:29
    
    clear betaOutput pTrl_burst ssrt trials 
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Load in beta output data for session
    loadFile = ['eeg_session' int2str(session) '_' sessionName 'pTrl_burst'];
    load([dataDir loadFile]) 
    
    pBurstData.canc_baseline(session,:) = pTrl_burst.baseline.canceled;
    pBurstData.canc_ssd(session,:) = pTrl_burst.ssd.canceled;
    pBurstData.canc_ssrt(session,:) = pTrl_burst.ssrt.canceled;

    pBurstData.noncanc_baseline(session,:) = pTrl_burst.baseline.noncanc;
    pBurstData.noncanc_ssd(session,:) = pTrl_burst.ssd.noncanc;
    pBurstData.noncanc_ssrt(session,:) = pTrl_burst.ssrt.noncanc;

    pBurstData.nostop_baseline(session,:) = pTrl_burst.baseline.nostop;
    pBurstData.nostop_ssd(session,:) = pTrl_burst.ssd.nostop;
    pBurstData.nostop_ssrt(session,:) = pTrl_burst.ssrt.nostop;

end

%%
clear boxplotData

groupLabels = [repmat({'No-stop'},29,1); repmat({'Non-canceled'},29,1); repmat({'Canceled'},29,1);...
    repmat({'No-stop'},29,1); repmat({'Non-canceled'},29,1); repmat({'Canceled'},29,1)];
epochLabels = [repmat({'Baseline'},29*3,1);repmat({'post-SSD'},29*3,1)];
burstData = [pBurstData.nostop_baseline; pBurstData.noncanc_baseline; pBurstData.canc_baseline;...
    pBurstData.nostop_ssd; pBurstData.noncanc_ssd; pBurstData.canc_ssd];

boxplotData(1,1)= gramm('x',groupLabels,'y',burstData,'color',epochLabels);

% Bar Chart
boxplotData(1,1).stat_summary('geom',{'bar','black_errorbar'},'type','sem');
boxplotData(1,1).set_color_options('map','d3.schemePaired')

%These functions can be called on arrays of gramm objects
boxplotData.set_names('x','Trial Type','y','p (burst | trial)');
boxplotData.axe_property('YLim',[0 0.25]);

figure('Position',[100 100 400 300]);
boxplotData.draw();

%%
%% Average band-filtered activity across all layers
% For each session
for sessionIdx = 1:length(perpendicularSessions)
    
    % Clear variables to reduce contamination
    clear corticalLFP_labels
    
    % Get session name (to load in relevant file)
    session = perpendicularSessions(sessionIdx);
    sessionName = FileNames{session};
    fprintf('Analysing session number %i of 29. \n',session);
    
    % Get trials for the given session
    trials.canceled = executiveBeh.ttm_CGO{session}.C_unmatched;
    trials.noncanceled = executiveBeh.ttx.NC{session};
    trials.nostop = executiveBeh.ttx.GO{session};
    
    % Get filtered channel data
    filter = 'lowGamma';
    inputDir = [matDir 'monkeyLFP\filtered\'];
    inFilename = ['laminarLFP_' filter '_session' int2str(session)];
    load([inputDir inFilename],'laminarLFP')
    
    % For each channel:
    for ii = 1:length(fieldnames(laminarLFP))
        % Get the relevant depth/channel
        depthlabel = ['corticalDepth_' int2str(ii)];
        
        % Average across three trial types: canceled, non-cancelled,
        % no-stop:
        channelAverageLFP.canc(ii,:) = nanmean(laminarLFP.(depthlabel)(trials.canceled,:));
        channelAverageLFP.noncanceled(ii,:) = nanmean(laminarLFP.(depthlabel)(trials.noncanceled,:));
        channelAverageLFP.nostop(ii,:) = nanmean(laminarLFP.(depthlabel)(trials.nostop,:));
    end
end

%%

        % //////////// COMMENTED: WAITING ON TARGET ALIGNED EXTRACTION ////////////
    % Calculate timing/proportion of bursts aligned on target/baseline

%     betaData{session}.baseline.canceled = SEF_stoppingEEG_getAverageBurstTimeLFP(session,channels,...
%         executiveBeh.ttx_canc, bayesianSSRT, [-400 -200], 'target');
%     betaData{session}.baseline.nostop = SEF_stoppingEEG_getAverageBurstTimeLFP(session,channels,...
%         executiveBeh.ttx.GO, bayesianSSRT, [-400 -200], 'target');
%     betaData{session}.baseline.noncanc = SEF_stoppingEEG_getAverageBurstTimeLFP(session,channels,...
%         executiveBeh.ttx.NC, bayesianSSRT, [-400 -200], 'target');


