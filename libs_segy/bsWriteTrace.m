function bsWriteTrace(GSegyInfo, traceHeader, data)
%% write one trace into segy file
%
% Programmed by: Bin She (Email: bin.stepbystep@gmail.com)
% Programming dates: Nov 2019
% -------------------------------------------------------------------------
% Input
% GSegyInfo     basical infomation of the segy file
% traceHeader   trace header information
% data          trace data to save
% -------------------------------------------------------------------------

    if(~GSegyInfo.isSaveCoordInfo)
        traceHeader.fullInfo(GSegyInfo.xCoordId, 1) = 0;
        traceHeader.fullInfo(GSegyInfo.yCoordId, 1) = 0;
    end
    
    traceHeader.fullInfo(GSegyInfo.inlineId, 1) = traceHeader.inId;                         % ��ȡinline��
    traceHeader.fullInfo(GSegyInfo.crosslineId, 1) = traceHeader.crossId;                   % ��ȡcrossline��
    traceHeader.fullInfo(GSegyInfo.offsetId, 1) = traceHeader.offset;                       % ��ȡ�ڼ����Ϣ
    
    traceHeader.fullInfo(GSegyInfo.traceSampNumId) = length(data);
    fwrite(GSegyInfo.fid, traceHeader.fullInfo, 'int32');
    
    fwrite(GSegyInfo.fid, data, 'float32');
end