power.allGamma = load('C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\power\laminarPower_allGamma_session14.mat');
power.beta = load('C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\power\laminarPower_beta_session14.mat');
lfp.allGamma = load('C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\filtered\laminarLFP_allGamma_session14.mat');
lfp.beta = load('C:\Users\Steven\Desktop\tempTEBA\matlabRepo\project_stoppingEEG\data\monkeyLFP\filtered\laminarLFP_beta_session14.mat');

laminarLFP_beta = lfp.beta.laminarLFP.stopSignal;
laminarLFP_gamma = lfp.allGamma.laminarLFP.stopSignal;

trls = executiveBeh.ttm_CGO{14}.C_matched;
time = [-999:2000];

figureSpace = [5:5:5*17];
depthSpace = depth_micrometers(1:17);

figure('Position',[100 100 600 500],'Renderer','Painters');
% For each channel:
for ii = 1:length(fieldnames(laminarLFP_beta))
    depthlabel = ['corticalDepth_' int2str(ii)];
    lfp_beta_mu(ii,:) = nanmean(laminarLFP_beta.(depthlabel)(trls,:));
    lfp_gamma_mu(ii,:) = nanmean(laminarLFP_gamma.(depthlabel)(trls,:));
    
    spacingValue = figureSpace(ii);
    
    subplot(1,2,1)
    plot(time,lfp_beta_mu(ii,:)+spacingValue,'k')
    hold on
    
    subplot(1,2,2)
    plot(time,lfp_gamma_mu(ii,:)+spacingValue,'k')
    hold on
end

subplot(1,2,1)
xlim([-250 500]); yticks(figureSpace); yticklabels(depthSpace)
xticks([-250:250:500]); xticklabels([-250:250:500])

vline(0,'r'); vline(bayesianSSRT.ssrt_mean(1),'r--'); hline(42.5,'k--')
set(gca,'YDir','reverse');
box off
xlabel('Time from SSD (ms)'); ylabel('Cortical depth (\mum)')

subplot(1,2,2)
xlim([-250 500]); yticks(figureSpace); yticklabels(depthSpace)
xticks([-250:250:500]); xticklabels([-250:250:500])

vline(0,'r'); vline(bayesianSSRT.ssrt_mean(1),'r--'); hline(42.5,'k--')
set(gca,'YDir','reverse');
box off


%%
% 
% laminarPower_beta = power.beta.laminarPower.hilbertPower.stopSignal;
% laminarPower_gamma = power.allGamma.laminarPower.hilbertPower.stopSignal;
% 
% trls = executiveBeh.ttm_CGO{14}.C_matched;
% time = [-999:2000];
% 
% figureSpace = [5:5:5*17];
% depthSpace = depth_micrometers(1:17);
% 
% figure('Position',[100 100 600 500]);
% % For each channel:
% for ii = 1:length(fieldnames(laminarPower_beta))
%     depthlabel = ['corticalDepth_' int2str(ii)];
%     power_beta_mu(ii,:) = nanmean(laminarPower_beta.(depthlabel)(trls,:));
%     power_gamma_mu(ii,:) = nanmean(laminarPower_gamma.(depthlabel)(trls,:));
%     
%     spacingValue = figureSpace(ii);
%     
%     subplot(1,2,1)
%     plot(time,power_beta_mu(ii,:)+spacingValue,'k')
%     hold on
%     
%     subplot(1,2,2)
%     plot(time,power_gamma_mu(ii,:)+spacingValue,'k')
%     hold on
% end
% 
% subplot(1,2,1)
% xlim([-250 500]); yticks(figureSpace); yticklabels(depthSpace)
% vline(0,'r'); vline(bayesianSSRT.ssrt_mean(1),'r--'); hline(42.5,'k--')
% set(gca,'YDir','reverse');
% box off
% xlabel('Time from SSD (ms)'); ylabel('Cortical depth (\mum)')
% 
% subplot(1,2,2)
% xlim([-250 500]); yticks(figureSpace); yticklabels(depthSpace)
% vline(0,'r'); vline(bayesianSSRT.ssrt_mean(1),'r--'); hline(42.5,'k--')
% set(gca,'YDir','reverse');
% box off
