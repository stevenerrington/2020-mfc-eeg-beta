
%% SETUP ANALYSIS & PARAMETERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup directories, get session information, and import
% pre-processed/pre-extracted behavioral information.

% Extract information about sessions
[sessionInformation] = SEF_stoppingEEG_getSessionInformation;

% Load relevant behavioral data
matDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\';
outputDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';

load([matDir 'behavior\bayesianSSRT']); load([matDir 'behavior\executiveBeh']); load([matDir 'behavior\FileNames'])

% Run parameter scripts
getColors; getAnalysisParameters;

%% EEG ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract Fronto-central EEG data for all sessions
% ***  Processing ***********************************************
% Extract neurophysiological data for EEG. Filter data for each session
% into the beta band, find beta bursts, find proportion of trials with burst.
SEF_stoppingEEG_EEG_getData

% **************************************************************
% *** Overall beta-burst proportions  **************************
% **************************************************************
% Get proportion of beta-bursts overall, observed in a baseline period and
% at an active period (0:200 ms post-target).
SEF_stoppingEEG_EEG_RestingBetaProportion

% **************************************************************
% ***  Stopping beta-burst *************************************
% **************************************************************
% Plot proportion of bursts by trial type (Figure 2)
SEF_stoppingEEG_EEG_pTrlBetaBurst_Boxplot

% Plot burst parameters (mu, sd, pBursts) by stopping behavior (mu & sd
% SSRT, trigger failures)(Figure 2)
SEF_stoppingEEG_EEG_burstTime_Correlation

% Plot burst times as a raster plot, and show proportion of bursts over
% time (Figure 2)
SEF_stoppingEEG_EEG_pTrlBetaBurst_Raster

% **************************************************************
% ***  Neurometric & psychometric approach  ********************
% **************************************************************

SEF_stoppingEEG_EEG_Neurometric


% **************************************************************
% ***  Performance beta-bursts **********************************
% **************************************************************
% Examine proactive control features
% Starting with error activity:
SEF_stoppingEEG_EEG_ErrorAnalysis

% ...and then post-stopping (conflict) activity:
SEF_stoppingEEG_EEG_SSRTAnalysis

% Look at changes in RT adaptation (beh & burst)
SEF_stoppingEEG_EEG_RTadaptation

% ... and then trial history effecst
SEF_stoppingEEG_EEG_TrialHistory




