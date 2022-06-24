clear all; clc
warning off

%% Get all session details/names/files
% Get directory where data is stored
monkeys = {'Joule','Broca'};

for monkeyIdx = 1:2
    monkeyLabel = monkeys{monkeyIdx};
    
    dataDir = ['C:\Users\Steven\Desktop\tempTEBA\dataRepo\2015_ChoiceCmand_BrJo\' monkeyLabel '\'];
    
    % Look through directory for relevant files
    sessionList = struct2table(dir(dataDir)); sessionList = cellstr(sessionList.name);
    sessionList = sessionList(3:end);
    sessionList = sessionList(cellfun(@isempty,strfind(sessionList,'_lfp.mat')));
    
    sessionInformation.(monkeyLabel) = table();
    
    % Go through files and get relevant details.
    for sessionIdx = 1:length(sessionList)
        fprintf('Extracting session information from session %i of %i... \n',sessionIdx,length(sessionList));
        clear sessionName sessionBehData
        
        sessionName = sessionList{sessionIdx};
        try
            sessionBehData = load([dataDir sessionName]);
            sessionInformation.(monkeyLabel).sessionName(sessionIdx,:) = sessionName; % Session name
            sessionInformation.(monkeyLabel).directory(sessionIdx,:) = dataDir; % Directory
            sessionInformation.(monkeyLabel).sessionIdx(sessionIdx,:) = sessionIdx; % Session idx (arbitary)
            sessionInformation.(monkeyLabel).task(sessionIdx,:) = {sessionBehData.SessionData.taskName}; % Task name
            sessionInformation.(monkeyLabel).hemisphere(sessionIdx,:) = {sessionBehData.SessionData.hemisphere}; % Hemisphere of recording
            sessionInformation.(monkeyLabel).date(sessionIdx,:) = sessionBehData.SessionData.date; % Date of recording
            
        catch
            continue
        end
    end
    
    % Find countermanding behavior and LFP
    countermandingSessions_beh.(monkeyLabel) = cellstr(sessionInformation.(monkeyLabel).sessionName(strcmp(sessionInformation.(monkeyLabel).task,'ChoiceCountermanding'),:));
    countermandingSessions_LFP.(monkeyLabel) = cellfun(@(x) insertAfter(x,8,"_LFP"),countermandingSessions_beh.(monkeyLabel),'UniformOutput',false);
    
end


%% Set behavioral parameters/labels/etc for this data set
nostop_trialLabels = {'goCorrectTarget','goCorrectDistractor'};
noncanceled_trialLabels = {'stopIncorrectTarget','stopIncorrectDistractor'};
canceled_trialLabels = {'stopCorrect'};

%% Get behavioral data from this set
clear sessionList
sessionList = countermandingSessions_beh.(monkeyLabel);

for sessionIdx = 1:length(sessionList)
    clear sessionName sessionBehData
    
    sessionName = sessionList{sessionIdx};
    sessionBehData = load([dataDir sessionName]);
    fprintf('Extracting behavior from session %i of %i... \n',sessionIdx,length(sessionList));
    
    if iscell(sessionBehData.rewardOn)
        sessionBehData.rewardOn = cell2mat(sessionBehData.rewardOn);
    end
    
    trialEventTimes_all{sessionIdx} = [sessionBehData.fixWindowEntered, sessionBehData.targOn,...
        sessionBehData.ssd, sessionBehData.responseOnset, NaN(length(sessionBehData.ssd),1),...
        sessionBehData.toneOn, sessionBehData.rewardOn];
    
    ttx{sessionIdx}.canceled = find(cell2mat(cellfun(@(x)...
        ismember(x, lower(canceled_trialLabels)), lower(sessionBehData.trialOutcome), 'UniformOutput', 0)));
    
    ttx{sessionIdx}.noncanceled = find(cell2mat(cellfun(@(x)...
        ismember(x, lower(noncanceled_trialLabels)), lower(sessionBehData.trialOutcome), 'UniformOutput', 0)));
    
    ttx{sessionIdx}.nostop = find(cell2mat(cellfun(@(x)...
        ismember(x, lower(nostop_trialLabels)), lower(sessionBehData.trialOutcome), 'UniformOutput', 0)));
    
end

%% Get stopping behavior

BEESTtable_allSessions = table();

for sessionIdx = 1:length(sessionList)
    clear sessionName sessionBehData
    
    sessionName = sessionList{sessionIdx};
    sessionBehData = load([dataDir sessionName]);
    fprintf('Extracting stopping behavior from session %i of %i... \n',sessionIdx,length(sessionList));
    
    
    % Classic stopping behavior
    inh_data{sessionIdx}.inh_SSD = unique(sessionBehData.ssd(~isnan(sessionBehData.ssd)))';
    
    for ssdIdx = 1:length(inh_data{sessionIdx}.inh_SSD)
        inh_data{sessionIdx}.inh_xTrls{ssdIdx} = find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx));
        inh_data{sessionIdx}.inh_nTrls(ssdIdx) = length(find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx)));
        inh_data{sessionIdx}.inh_nCanc(ssdIdx) = sum(ismember(ttx{sessionIdx}.canceled,find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx))));
        inh_data{sessionIdx}.inh_nNoncanc(ssdIdx) = sum(ismember(ttx{sessionIdx}.noncanceled,find(sessionBehData.ssd == inh_data{sessionIdx}.inh_SSD(ssdIdx))));
        inh_data{sessionIdx}.inh_pNC(ssdIdx) = inh_data{sessionIdx}.inh_nNoncanc(ssdIdx)/...
            inh_data{sessionIdx}.inh_nTrls(ssdIdx);
    end
    
    [inh_data{sessionIdx}.weibullParameters,~,inh_data{sessionIdx}.weibullFit(:,1),inh_data{sessionIdx}.weibullFit(:,2)] =...
        SEF_LFPToolbox_FitWeibull(inh_data{sessionIdx}.inh_SSD, inh_data{sessionIdx}.inh_pNC, inh_data{sessionIdx}.inh_nTrls);
    
    
    % BEESTS stopping behavior
    
    subj_idx = repmat(sessionIdx,length(sessionBehData.trialOnset),1);
    ss_presented = double(~isnan(sessionBehData.ssd));
    inhibited = double([ismember(1:length(sessionBehData.trialOnset),ttx{sessionIdx}.canceled)]');
    ssd = sessionBehData.ssd;
    rt = sessionBehData.rt;
    
    inhibited(ss_presented == 0) = -999;
    ssd(ss_presented == 0) = -999;
    rt(inhibited == 1) = -999;
    
    
    BEESTtable{sessionIdx} = table(subj_idx,ss_presented,inhibited,ssd,rt);
    BEESTtable{sessionIdx}(isnan(BEESTtable{sessionIdx}.rt),:) = [];
    BEESTtable{sessionIdx}(BEESTtable{sessionIdx}.rt > 1500,:) = [];
    
    BEESTtable_allSessions = [BEESTtable_allSessions;BEESTtable{sessionIdx}];
    
end


% Output to BEESTs for analysis
writetable(BEESTtable_allSessions,'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\behavior\BEEST\FEF_JoBeh.csv', 'WriteRowNames',true)

% Get SSRT and trigger failures from BEEST




%% Look at LFP's





