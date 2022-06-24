function [signalPower, adjSignalPower, normSignalPower, hilbertPower] = ...
    getTrialPower(alignedLFP, filterFreq, ephysParameters, normTime)

if nargin < 4
    normTime = [600:800]; % corresponds to -400 ms to -200 ms pre-event.
end

highpassThreshold = filterFreq(1);

for trl = 1:size(alignedLFP,1)
    
    signalAbs = abs(alignedLFP(trl,:));
    signalPower(trl,:) = SEF_LFP_Filter(signalAbs,0.1,...
        filterFreq(1)/2, ephysParameters.samplingFreq);
    
    adjSignalPower(trl,:) = signalPower(trl,:)-(mean(signalPower(trl,normTime)));
    normSignalPower(trl,:) = (signalPower(trl,:)-mean(signalPower(trl,normTime)))./(std(signalPower(trl,normTime)));
    
    
    hilbertTransform = hilbert(alignedLFP(trl,:));
    hilbertPower(trl,:) = abs(hilbertTransform);  
    
end
