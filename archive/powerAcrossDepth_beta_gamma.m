pwrDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\power\';
filterLabels = {'allGamma','beta'};

count = 0;
for session = 14:22%:29
    count = count+1;
    
    % session parameters
    trials = executiveBeh.ttx.GO{session};
    window = -500:0;
    offset = 1000;
    window = window + offset;
    
    for filterIdx = 1:length(filterLabels)
        filter = filterLabels{filterIdx};
        sessionFile = ['laminarPower_' filter '_session' int2str(session)];
        load([pwrDir sessionFile])
        
        clear inputData
        inputData = laminarPower.hilbertPower.target;
        
        depthNames = fieldnames(inputData);
        
        for depthIdx = 1:length(depthNames)
            depth = depthNames{depthIdx};
            
            clear powerData
            powerData = inputData.(depth);
            
            depth_averagePower.(filter)(depthIdx,count) = nanmean(nanmean(powerData(trials,window)));
        end
        
        depth_averagePower.(filter)(:,count) = depth_averagePower.(filter)(:,count)./...
            max(depth_averagePower.(filter)(:,count));
    end
end

%%

figure;
plot(nanmean(depth_averagePower.beta,2), depth_micrometers(1:17) ,'b-')
hold on
plot(nanmean(depth_averagePower.allGamma,2), depth_micrometers(1:17) ,'r-')
set(gca,'YDir','normal');
xlim([0.5 1])
