
zrft_allSessions = [];

for session = 1:29
    clear ssdList
    
    ssdList = executiveBeh.inh_SSD{session};
    nSSDs = length(ssdList);
    
    nostop_RT  = nanmean(executiveBeh.RTdata.RTinfo.all{session}.goRT.dist);
    nostop_RTsd  = nanstd(executiveBeh.RTdata.RTinfo.all{session}.goRT.dist);
    ssrt = bayesianSSRT.ssrt_mean(session);
    
    for ssdIdx = 1:nSSDs
        ssdX = ssdList(ssdIdx);
        executiveBeh.inh_ZRFT{session}(ssdIdx) = (nostop_RT - ssdX - ssrt)./nostop_RTsd;
    end
    
    zrft_allSessions = [zrft_allSessions;...
        executiveBeh.inh_ZRFT{session}',executiveBeh.inh_pNC{session}',executiveBeh.inh_trcount_SSD{session}'];
    
end

[bestFitParams,~,~,~] = SEF_Toolbox_FitWeibull(zrft_allSessions(:,1),...
 zrft_allSessions(:,2), zrft_allSessions(:,3));

g(1,1)=gramm('x',zrft_allSessions(:,1),'y',zrft_allSessions(:,2));
g(1,1).geom_point(); g(1,1).set_color_options('map',[0.25 0.25 0.25]);
g(1,1).set_names('x','ZRFT','y','p (respond|stop-signal)');
% g(1,1).axe_property('XLim',[-4 4]);

figure('Position',[100 100 300 300]);
g.draw();