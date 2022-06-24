function burstITI = BetaBurst_Intervals (betaBurstTimes)



burstITI = [];

for trl = 1:length(betaBurstTimes)
   
    burstTimes = betaBurstTimes{trl}
    
    if isempty(burstTimes)
        continue
    else
       burstITI = [burstITI;diff(burstTimes)];

    end
   
end



