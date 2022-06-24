pBurst_SSD_allsessions.C_matched = [];
pBurst_SSD_allsessions.GO_matched = [];
outputDir = 'C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyEEG\';


for session = 1:29
    sessionName = FileNames{session};
    
    % Load in beta output data for session
    loadname = ['betaBurst\eeg_session' int2str(session) '_' sessionName '_betaOutput'];
    load([outputDir loadname],'betaOutput')
    
    clear ssd pBurst_SSD

    ssd = executiveBeh.inh_SSD{session};
    
    for trialTypeIdx = 1:2
        if trialTypeIdx == 1
            trialType = 'C_matched';
        else
            trialType = 'GO_matched';
        end
        
        for ssdIdx = 1:length(ssd)
            clear trialList nBurst_SSD
            trialList = executiveBeh.ttm_CGO{session,ssdIdx}.(trialType);
            
            for trlIdx = 1:length(trialList)
                nBurst_SSD(trlIdx,1) = ...
                    sum(betaOutput.burstData.burstTime{trialList(trlIdx)} > 0 &...
                    betaOutput.burstData.burstTime{trialList(trlIdx)}...
                    <= bayesianSSRT.ssrt_mean(session)) > 0;
                
            end
            
            if length(trialList) > 20
                pBurst_SSD(ssdIdx,1) = nanmean(nBurst_SSD(:,1));
            else
                pBurst_SSD(ssdIdx,1) = NaN;
            end
            
        end
        pBurst_SSD_allsessions.(trialType) = [pBurst_SSD_allsessions.(trialType); pBurst_SSD, ssd', executiveBeh.inh_pNC{session}', executiveBeh.inh_ZRFT{session}'];

    end
end


pBurst_SSD_allsessions.C_matched = pBurst_SSD_allsessions.C_matched(find(~isnan(pBurst_SSD_allsessions.C_matched(:,1))),:);
pBurst_SSD_allsessions.GO_matched = pBurst_SSD_allsessions.GO_matched(find(~isnan(pBurst_SSD_allsessions.GO_matched(:,1))),:);

clear g
g(1,1)= gramm('x',pBurst_SSD_allsessions.C_matched(:,2),'y',pBurst_SSD_allsessions.C_matched(:,1));
g(1,2)= gramm('x',pBurst_SSD_allsessions.C_matched(:,3),'y',pBurst_SSD_allsessions.C_matched(:,1));
g(1,3)= gramm('x',pBurst_SSD_allsessions.C_matched(:,4),'y',pBurst_SSD_allsessions.C_matched(:,1));

g(2,1)= gramm('x',pBurst_SSD_allsessions.GO_matched(:,2),'y',pBurst_SSD_allsessions.C_matched(:,1)-pBurst_SSD_allsessions.GO_matched(:,1));
g(2,2)= gramm('x',pBurst_SSD_allsessions.GO_matched(:,3),'y',pBurst_SSD_allsessions.C_matched(:,1)-pBurst_SSD_allsessions.GO_matched(:,1));
g(2,3)= gramm('x',pBurst_SSD_allsessions.GO_matched(:,4),'y',pBurst_SSD_allsessions.C_matched(:,1)-pBurst_SSD_allsessions.GO_matched(:,1));

g(1,1).geom_point(); g(1,1).stat_glm();
g(1,2).geom_point(); g(1,2).stat_glm();
g(1,3).geom_point(); g(1,3).stat_glm();

g(2,1).geom_point(); g(2,1).stat_glm();
g(2,2).geom_point(); g(2,2).stat_glm();
g(2,3).geom_point(); g(2,3).stat_glm();

g(:,2).axe_property('XLim',[-0.05 1.05]);
% g(2,2).axe_property('XLim',[-0.05 1.05]);
g(1,:).axe_property('YLim',[-0.05 0.4]);
g(2,:).axe_property('YLim',[-0.25 0.25]);

g(1,:).set_color_options('map',colors.canceled);
% g(1,2).set_color_options('map',[65 182 196]./255);
% g(1,3).set_color_options('map',[65 182 196]./255);
g(2,:).set_color_options('map',[65 182 196]./255);
% g(2,2).set_color_options('map',[65 182 196]./255);
% g(2,3).set_color_options('map',[65 182 196]./255);

figure('Position',[100 100 700 400]);
g.draw();

%%
for ii = 1:2
    for jj = 1:3
        r(ii,jj) = g(ii, jj).results.stat_glm.model.Rsquared.Ordinary;
        p(ii,jj) = g(ii, jj).results.stat_glm.model.Coefficients.pValue(2);
    end
end
    
    