function [outLogs] = bsGetPairOfInvAndWell(GInvParam, timeLine, wellLogs, invResults, dataIndex, options)
    nWell = length(wellLogs);
    
    wells = cell2mat(wellLogs);
    wellInIds = [wells.inline];
    wellCrossIds = [wells.crossline];
    
    usedTimeLine = timeLine{GInvParam.usedTimeLineId};
    wellHorizonTimes = bsGetHorizonTime(usedTimeLine, ...
        wellInIds, wellCrossIds);
    indexInWellData = GInvParam.indexInWellData;
        GInvParam.upNum = GInvParam.upNum;
        GInvParam.downNum = GInvParam.downNum;
    outLogs = cell(1, nWell);
    
    % re-organize the data, and add the error data at the last column;
    for i = 1 : nWell
        
        wellInfo = wellLogs{i};
        

        wellData = bsExtractWellDataByHorizon(...
                wellInfo.wellLog, ...
                wellHorizonTimes(i), ...
                dataIndex, ...
                indexInWellData.time, ...
                GInvParam.upNum, ...
                GInvParam.downNum, ...
                1);
            
        switch options.mode
            case 'full_freq'
                wellData = bsButtLowPassFilter(wellData, options.highCut);

            case 'low_high'
                % ��ͨ�˲�
                wellData = bsButtBandPassFilter(wellData, options.lowCut, options.highCut);
                % ��ͨ�˲�
%                 invResults(:, i) = bsButtLowPassFilter(invResults(:, i), options.lowCut);
        end
        
        wellInfo.wellLog = [invResults(:, i), wellData];
        
        outLogs{i} = wellInfo;
        
    end
    
end