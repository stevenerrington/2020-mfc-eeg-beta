function lfpPower_meanFreq = averageMorletFreqPower(inputTrials, morletLFP)

% For each trial
for trlIdx = 1:length(inputTrials)
    trl = inputTrials(trlIdx);
    
    % Get Morlet power, across all frequencies
    lfpPower_trl = squeeze(morletLFP(trl,:,:));
    
    % Average across frequencies
    lfpPower_meanFreq(trlIdx,:) = mean(lfpPower_trl,2);
end




