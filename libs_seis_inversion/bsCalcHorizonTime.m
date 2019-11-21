function [horizonTimes] = bsCalcHorizonTime(usedTimeLine, inIds, crossIds)
%% get the horizon of given traces
    
    nTrace = length(inIds);
    horizonTimes = zeros(1, nTrace);
    
    for i = 1 : nTrace
        try
            [~, ~, horizonTimes(i)] = bsCalcWellBaseInfo(usedTimeLine, ...
                inIds(i), crossIds(i), 1, 2, 1, 2, 3);
        catch
            error('%d trace is failed!!!', i);
        end
        
    end
    
    
    
end