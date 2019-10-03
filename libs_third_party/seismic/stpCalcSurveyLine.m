function [outInIds, outCrossIds] = stpCalcSurveyLine(inIds, crossIds, firstCdp, traceNum)
% ����һ��������ߵĺ���
%
% ���
% outInIds              �����inline
% outCrossIds           �����crossline
%
% ����
% inIds                 �����inline
% crossIds              �����crossline
% firstCdp              ��һ��crossline��
% traceNum              ���ߵĵ���

    endCdp = firstCdp + traceNum - 1;
    
%     setInIds = [2900, inIds, inIds(length(inIds))];
    if(length(inIds) == 1)
        setInIds = [inIds(1), inIds, inIds(length(inIds))];
        setCrossIds = [firstCdp, crossIds, endCdp];
    else
        setInIds = inIds;
        setCrossIds = crossIds;
    end
    
%     setInIds = [2904, inIds, 2468];
%     setInIds = [2560, inIds, 2903];
    
    
    outCrossIds = firstCdp : 1 : endCdp;
    outInIds = stpCubicSpline(setCrossIds, setInIds, outCrossIds, 0, 0);

    % ����ȡ��
    for i = 1 : length(outInIds)
        outInIds(i) = floor(outInIds(i));
    end
    
    for i = 1 : length(crossIds)
        index = find(outCrossIds == crossIds(i));
        outInIds(index) = inIds(i);
    end

%     figure;
%     plot(outCrossIds, outInIds, 'r'); set(gca,'ydir','reverse');
%     hold on;
% %     text(crossIds, inIds, wellNames, 'FontSize', 8);
% %     set(gca, 'ylim', [2550 2950]);
%     xlabel('Crossline','FontSize',14);ylabel('Inline','FontSize',14);
%     title('����λ������', 'FontSize', 18);
end