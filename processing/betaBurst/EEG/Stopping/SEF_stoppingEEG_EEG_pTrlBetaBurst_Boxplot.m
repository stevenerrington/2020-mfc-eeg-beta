matDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\behavior\';
dataDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';
load([matDir 'bayesianSSRT']); load([matDir 'executiveBeh']); load([matDir 'FileNames'])

%% Calculate proportion of trials with burst
pBurstData = table();

sessionList = 1:29;

for sessionIdx = 1:length(sessionList)
    session = sessionList(sessionIdx);
    
    clear betaOutput pTrl_burst ssrt trials 
    % Get session name (to load in relevant file)
    sessionName = FileNames{session};
    fprintf(['Analysing session number %i of ' int2str(length(sessionList)) '. \n'], session);
    
    % Load in beta output data for session
    loadFile = ['pBurst\eeg_session' int2str(session) '_' sessionName 'pTrl_burst'];
    load([dataDir loadFile]) 
    
    pBurstData.canc_baseline(sessionIdx,:) = pTrl_burst.baseline.canceled;
    pBurstData.canc_ssd(sessionIdx,:) = pTrl_burst.ssd.canceled;
    pBurstData.canc_ssrt(sessionIdx,:) = pTrl_burst.ssrt.canceled;

    pBurstData.noncanc_baseline(sessionIdx,:) = pTrl_burst.baseline.noncanc;
    pBurstData.noncanc_ssd(sessionIdx,:) = pTrl_burst.ssd.noncanc;
    pBurstData.noncanc_ssrt(sessionIdx,:) = pTrl_burst.ssrt.noncanc;

    pBurstData.nostop_baseline(sessionIdx,:) = pTrl_burst.baseline.nostop;
    pBurstData.nostop_ssd(sessionIdx,:) = pTrl_burst.ssd.nostop;
    pBurstData.nostop_ssrt(sessionIdx,:) = pTrl_burst.ssrt.nostop;

end

%%
clear pBurst_trialType groupLabels epochLabels burstData

groupLabels = [repmat({'No-stop'},length(sessionList),1); repmat({'Non-canceled'},length(sessionList),1); repmat({'Canceled'},length(sessionList),1);...
    repmat({'No-stop'},length(sessionList),1); repmat({'Non-canceled'},length(sessionList),1); repmat({'Canceled'},length(sessionList),1)];
epochLabels = [repmat({'Baseline'},length(sessionList)*3,1);repmat({'post-SSD'},length(sessionList)*3,1)];
burstData = [pBurstData.nostop_baseline; pBurstData.noncanc_baseline; pBurstData.canc_baseline;...
    pBurstData.nostop_ssd; pBurstData.noncanc_ssd; pBurstData.canc_ssd];

pBurst_trialType(1,1)= gramm('x',groupLabels,'y',burstData,'color',epochLabels);

pBurst_trialType(1,1).stat_violin();
pBurst_trialType(1,1).geom_jitter('alpha',0.5,'dodge',0.75);

pBurst_trialType.set_color_options('map','d3.schemePaired');

figure('Renderer', 'painters', 'Position', [100 100 400 300]);
pBurst_trialType.draw();


%% Export to JASP

BL_C = pBurstData.canc_baseline;
BL_NC = pBurstData.noncanc_baseline;
BL_NS = pBurstData.nostop_baseline;

SSD_C = pBurstData.canc_ssd;
SSD_NC = pBurstData.noncanc_ssd;
SSD_NS = pBurstData.nostop_ssd;

betaBurst_trialType = table(BL_C, BL_NC, BL_NS, SSD_C, SSD_NC, SSD_NS);

writetable(betaBurst_trialType,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\exportJASP\EEG_pBurst_trlType.csv','WriteRowNames',true) 