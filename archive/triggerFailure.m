
%% SETUP ANALYSIS & PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup directories, get session information, and import
% pre-processed/pre-extracted behavioral information.

% Extract information about sessions
[sessionInformation] = SEF_stoppingEEG_getSessionInformation;

% Load relevant behavioral data
matDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\';

load([matDir 'behavior\bayesianSSRT']); load([matDir 'behavior\executiveBeh']); load([matDir 'behavior\FileNames'])

% Run parameter scripts
getColors; getAnalysisParameters;

outputDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';
% Load parameters for analysis
getAnalysisParameters; % Separate script holding all key parameters.
      

%% Get data from frontal electrode

for eventType = 3
    eventLabel = eventNames{eventType};
    alignmentParameters.eventN = eventType;
    fprintf(['Analysing data aligned on ' eventLabel '. \n']);
    
    %% Extract EEG data & calculate power
    for session = 1:29
        fprintf('...extracting beta on session number %i of 29. \n',session);
        % Get session name (to load in relevant file)
        sessionName = FileNames{session};
        
        % Clear workspace
        clear trials eventTimes inputLFP cleanLFP alignedLFP filteredLFP betaOutput morletLFP pTrl_burst
        
        % Setup key behavior variables
        ssrt = bayesianSSRT.ssrt_mean(session);
        eventTimes = executiveBeh.TrialEventTimes_Overall{session};
 
        % Load raw signal
        inputLFP = load(['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2012_Cmand_EuX\rawData\' sessionName],...
            'AD01');
        
        % Pre-process & filter analog data (EEG/LFP), and align on event
        filter = 'all';
        filterFreq = filterBands.(filter);
        [~,FCz{session}] = tidyRawSignal(inputLFP.AD01, ephysParameters, [1 30],...
            eventTimes, alignmentParameters);       
        
    end
end

%% 
lowTFsessions = find(bayesianSSRT.triggerFailures <= median(bayesianSSRT.triggerFailures));
highTFsessions = find(bayesianSSRT.triggerFailures > median(bayesianSSRT.triggerFailures));

executiveBeh.nhpSessions.monkeyNameLabel(highTFsessions)
%% 
window = [750:1500];
time = [-250:500];

for sessionIdx = 1:length(lowTFsessions)
    session = lowTFsessions(sessionIdx);
    cFCz_mean.lowTF{sessionIdx,1} = nanmean(FCz{session}(executiveBeh.ttm_c.C{session}.all,window)) - nanmean(nanmean(FCz{session}(executiveBeh.ttm_c.C{session}.all,750:950))) ;
    ncFCz_mean.lowTF{sessionIdx,1} = nanmean(FCz{session}(executiveBeh.ttm_c.NC{session}.all,window)) - nanmean(nanmean(FCz{session}(executiveBeh.ttm_c.NC{session}.all,750:950))) ;
end

for sessionIdx = 1:length(highTFsessions)
    session = highTFsessions(sessionIdx);
    cFCz_mean.highTF{sessionIdx,1} = nanmean(FCz{session}(executiveBeh.ttm_c.C{session}.all,window)) - nanmean(nanmean(FCz{session}(executiveBeh.ttm_c.C{session}.all,750:950))) ;
    ncFCz_mean.highTF{sessionIdx,1} = nanmean(FCz{session}(executiveBeh.ttm_c.NC{session}.all,window)) - nanmean(nanmean(FCz{session}(executiveBeh.ttm_c.C{session}.all,750:950))) ;
end


test(1,1)=gramm('x',time,'y',[cFCz_mean.lowTF;ncFCz_mean.lowTF],...
    'color',[repmat({'Canceled'},length(cFCz_mean.lowTF),1);repmat({'Non-canceled'},length(ncFCz_mean.lowTF),1)]); 
test(1,1).stat_summary();
test(1,1).axe_property('YLim',[-15 15]);

test(2,1)=gramm('x',time,'y',[cFCz_mean.highTF;ncFCz_mean.highTF],...
    'color',[repmat({'Canceled'},length(cFCz_mean.highTF),1);repmat({'Non-canceled'},length(ncFCz_mean.highTF),1)]); 
test(2,1).stat_summary();
test(2,1).axe_property('YLim',[-15 15]);
test.set_color_options('map',[colors.canceled;colors.noncanc]);
test.axe_property('YDir','reverse')
figure('Renderer', 'painters', 'Position', [500 300 700 600]);
test.draw();


