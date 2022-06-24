clear betaValuesSession
for session = 17
    clear nTrls goTrls cTrls betaValuesSession
    
%     goTrls = executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.GO_matched;
%     cTrls = executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.C_matched;
%     
    inputTrls1 = executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.GO_matched;
    inputTrls2 = executiveBeh.ttm_CGO{session,executiveBeh.midSSDindex(session)}.C_matched;
    
    for trl = 1:length(inputTrls1)
        betaValuesSession.stopSignal.A{trl} = betaConvolved.stopSignal{session}(inputTrls1(trl),:);
    end
    
    for trl = 1:length(inputTrls2)
        betaValuesSession.stopSignal.B{trl} = betaConvolved.stopSignal{session}(inputTrls2(trl),:);
    end
end



%%

% Example movement neuron
jo_fef_movement = load('C:\Users\Steven\Desktop\tempTEBA\dataRepo\2015_ChoiceCmand_BrJo\Joule\jp090n02');
close all

neurons = {'spikeUnit25a'};

for ii = 1:length(neurons)
    clear test
    
    clear stopTrlIdx stopSignalWindow SDF
    stopSignalWindow = [(jo_fef_movement.responseCueOn)-500+257,...
        (jo_fef_movement.responseCueOn)+1000+257];
    
    clear SDF
    SDF = nan(length(jo_fef_movement.stopSignalOn),10000);
    inputUnit = neurons{ii};
    
    for trlIdx = 1:length(jo_fef_movement.targOn)
        trl = trlIdx;
        
        SDF(trl,:) = SpkConvolver(jo_fef_movement.(inputUnit){trl}...
            (jo_fef_movement.(inputUnit){trl} > 0 & jo_fef_movement.(inputUnit){trl} < 9000),...
            10000, 'PSP');
    end
    
    SDF = SDF*1000;
    
    clear goTrls cTrls goSDF cSDF
    goTrls = find(strcmp(jo_fef_movement.trialOutcome,'goCorrectTarget') & jo_fef_movement.responseOnset > jo_fef_movement.responseCueOn+257+80);
    cTrls = find(strcmp(jo_fef_movement.trialOutcome,'stopCorrect') & jo_fef_movement.ssd == 257);
    
    for goIdx = 1:length(goTrls)
        goSDF{goIdx}(1,:) = SDF(goTrls(goIdx),[stopSignalWindow(goTrls(goIdx),1):stopSignalWindow(goTrls(goIdx),2)]);
    end
    for cIdx = 1:length(cTrls)
        cSDF{cIdx}(1,:) = SDF(cTrls(cIdx),[stopSignalWindow(cTrls(cIdx),1):stopSignalWindow(cTrls(cIdx),2)]);
    end
    
end

clear test
timeBBDF = [-1000:2000]; timeSDF = [-500:1000];
test(1,1)=gramm('x',timeBBDF,'y',[betaValuesSession.stopSignal.A';betaValuesSession.stopSignal.B'],...
    'color',[repmat({'A'},length(inputTrls1),1);repmat({'B'},length(inputTrls2),1)]);
test(2,1)=gramm('x',timeSDF,'y',[goSDF';cSDF'],...
    'color',[repmat({'A'},length(goTrls),1);repmat({'B'},length(cTrls),1)]);

test(1,1).stat_summary(); test(2,1).stat_summary(); 

test(1,1).axe_property('XLim',[-250 500]);
test(1,1).axe_property('YLim',[0.0000 0.0075]);
test(2,1).axe_property('XLim',[-250 500]);
test(2,1).axe_property('YLim',[0 30]);

test.set_color_options('map',[colors.nostop;colors.canceled]);

figure('Position',[100 100 350 500]);
test.draw();

% 
% time = [-500:1000];
% figure;
% plot(time,nanmean(goSDF),'b'); hold on
% plot(time,nanmean(cSDF),'r')
% vline(0,'k-'); xlabel('Time from Target (ms)')
% vline(257,'k--')
% vline(257+80,'k-.')
% xlim([-250 800])