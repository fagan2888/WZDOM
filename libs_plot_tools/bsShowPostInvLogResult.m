function bsShowPostInvLogResult(GPostInvParam, GPlotParam, GShowProfileParam, model, invVals, methods, trueLogFiltcoef)

    nItems = length(invVals);
    sampNum = size(model.trueLog, 1);
    t = (model.t0 : GPostInvParam.dt : model.t0 + (sampNum-1)*GPostInvParam.dt) / 1000;
    
    hf = figure;
    
    for iItem = 1 : nItems
        
        figure(hf);
        switch nItems
            case {1, 2, 3}
                set(gcf, 'position', [  336   240   509   406]);
            case 4
                set(gcf, 'position', [  336   240   678   406]);
            case 5
                set(gcf, 'position', [  336   240   636   406]);
            otherwise
                set(gcf, 'position', [687   134   658   543]);
        end

        invVal = invVals{iItem};
        trueLog = model.trueLog;
        
        if trueLogFiltcoef>0 && trueLogFiltcoef<1
            trueLog = bsButtLowPassFilter(trueLog, trueLogFiltcoef);
        end
        
        bsShowPostSubInvLogResult(GPlotParam, ...
            invVal/1000, trueLog/1000, model.initLog/1000, ...
            t, methods{iItem}.name, ...
            GShowProfileParam.rangeIP/1000, nItems, iItem, GShowProfileParam.isLegend);

    end

    hL = subplot('position', [0.25    0.02    0.500    0.04]);
    poshL = get(hL,'position');     % Getting its position

    plot(0, 0, 'g', 'linewidth', GPlotParam.linewidth); hold on;
    plot(0, 0, 'k', 'LineWidth', GPlotParam.linewidth);   hold on;
    plot(0, 0, 'r','LineWidth', GPlotParam.linewidth);    hold on;
    

    lgd = legend(hL, 'Initial model', 'Real model', 'Inversion result');
    
    set(lgd,'Orientation','horizon', 'fontsize', GPlotParam.fontsize,'fontweight', 'bold', 'fontname', GPlotParam.fontname);
    set(lgd,'position',poshL);      % Adjusting legend's position
    axis(hL,'off');                 % Turning its axis off
    annotation('textbox', [0.05, 0.07, 0, 0], 'string', 'I_{\it{P}} (g/cc*km/s)', ...
        'edgecolor', 'none', 'fitboxtotext', 'on', ...
        'fontsize', GPlotParam.fontsize,'fontweight', 'bold', 'fontname', GPlotParam.fontname);
end


function bsShowPostSubInvLogResult(GPlotParam, ...
    invVal, trueVal, initVal, ...
    t, tmethod, range, nItems, iItem, isLegend)

    ichar = char( 'a' + (iItem-1) );
    switch nItems
        case {1, 2, 3}
            bsSubPlotFit(1, nItems, iItem, 0.96, 0.92, 0.08, 0.11, 0.085, 0.045);
        case 4
            bsSubPlotFit(1, nItems, iItem, 0.96, 0.92, 0.08, 0.11, 0.085, 0.045);
    end
    
    plot(initVal, t, 'g', 'linewidth', GPlotParam.linewidth); hold on;
    plot(trueVal, t, 'k', 'LineWidth', GPlotParam.linewidth);   hold on;
    plot(invVal, t, 'r','LineWidth', GPlotParam.linewidth);    hold on;
    
    
    ylabel('Time (s)');
%     xlabel('I_{\it{P}} (g/cc*km/s)');
        
    set(gca,'ydir','reverse');
    
    if isLegend 
        legend('Initial model', 'Real model', 'Inversion result');
    end
    
    title(sprintf('(%s) %s', ichar, tmethod));
    set(gca, 'xlim', range) ; 
    set(gca, 'ylim', [t(1) t(end)]);
%     bsTextSeqIdFit(ichar - 'a' + 1, 0, 0, 12);

    set(gca , 'fontsize', GPlotParam.fontsize,'fontweight', GPlotParam.fontweight, 'fontname', GPlotParam.fontname);
end