function postSeisData = bsGetPostSeisData(GInvParam, inIds, crossIds, startTime, sampNum)

    if isfield(GInvParam, 'postSeisData') && exist(GInvParam.postSeisData.fileName, 'file')
        [postSeisData, ~] = bsReadTracesByIds(...
            GInvParam.postSeisData.fileName, ...
            GInvParam.postSeisData.segyInfo, ...
            inIds, ...
            crossIds, ...
            startTime, ...
            sampNum, ...
            GInvParam.dt);
    else
        postSeisData = bsStackPreSeisData(...
            GInvParam.preSeisData.fileName, ...
            GInvParam.preSeisData.segyInfo, ...
            inIds, ...
            crossIds, ...
            startTime, ...
            sampNum, ...
            GInvParam.dt);
    end
    
end