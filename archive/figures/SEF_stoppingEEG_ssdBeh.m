ssdBeh_allsession = []; clear ssdBeh monkeyMatrix
goRT =[]; ncRT = [];

for session = 1:29
    
    ssdBeh_allsession = [ssdBeh_allsession;executiveBeh.inh_SSD{session}',...
        executiveBeh.inh_pNC{session}',...
        executiveBeh.inh_trcount_SSD{session}',...
        executiveBeh.inh_ZRFT{session}'];
    
    [~,~,~,ssdBeh{session}] = SEF_LFPToolbox_FitWeibull...
        (executiveBeh.inh_SSD{session},...
        executiveBeh.inh_pNC{session},...
        executiveBeh.inh_trcount_SSD{session});
    
    goRT = [goRT; executiveBeh.RTdata.RTinfo.all{session}.goRT.CumulativeDistribition(:,1)];
    ncRT = [ncRT; executiveBeh.RTdata.RTinfo.all{session}.ncRT.CumulativeDistribition(:,1)];
    
    if ismember(session,executiveBeh.nhpSessions.EuSessions)
        monkeyMatrix{session} = 'Monkey Eu';
    else
        monkeyMatrix{session} = 'Monkey X';
    end
    
end

go_CDF = SEF_Toolbox_CumulativeDistribition(goRT,'-',2,[1,0,0] , 0);
nc_CDF = SEF_Toolbox_CumulativeDistribition(ncRT,'-',2,[1,0,0] , 0);

rtArray = [go_CDF; nc_CDF];
labels = [repmat({'No-stop'},length(go_CDF),1); repmat({'Non-canceled'},length(nc_CDF),1)];
    

ssdtime = 1:600;

clear g
g(1,1)=gramm('x',rtArray(:,1),'y',rtArray(:,2),'color',labels); % RT CDF
g(1,2)=gramm('x',ssdtime,'y',ssdBeh,'color',monkeyMatrix); % Inhibition function
g(2,1)=gramm('x',bayesianSSRT.ssrt_mean); % SSRT distribution
g(2,2)=gramm('x',bayesianSSRT.triggerFailures); % SSRT distribution

g(1,1).stat_summary()
g(1,2).stat_summary()
g(2,1).stat_bin('edges',50:10:200,'geom','overlaid_bar');
g(2,2).stat_bin('edges',0:0.01:0.2,'geom','overlaid_bar');

g(1,1).no_legend();  g(2,1).no_legend(); g(2,2).no_legend();
g(1,1).axe_property('XLim',[0 600]);

g(1,1).set_names('x','Response latency (ms)','y','CDF');
g(1,2).set_names('x','Stop-signal delay (ms)','y','P(Respond | Stop-Signal)');
g(2,1).set_names('x','Stop-signal reaction time (ms)','y','Frequency');
g(2,2).set_names('x','P(Trigger Failures)','y','Frequency');

g(1,1).set_color_options('map',[colors.nostop; colors.noncanc]);
g(1,2).set_color_options('map',[colors.euler;colors.xena])
g(2,:).set_color_options('map','matlab')
figure('Position',[100 100 450 400]);
g.draw();


%%