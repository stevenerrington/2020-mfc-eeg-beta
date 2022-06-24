session = 14;

inputTrls = executiveBeh.ttx_canc{session};...
%     (randi(length(executiveBeh.ttx_canc{session}),12,1));

    % Plot heatmap of beta activity on trial-by-trial basis
    plotBeta_indTrls12(inputTrls, morletParameters.frequencies,...
        bayesianSSRT.ssrt_mean(14), morletLFP, 'All')
    
    for 