function bsShowSubProfile(GPostInvParam, GPlotParam, GShowProfileParam, ...
    profileData, horizon, firstCdp, ... 
    isShowHorizon, filtCoef, tstr, range, color, wellPos, wellData)

   
    if(GShowProfileParam.upNum == 0)
        options.upNum = GPostInvParam.upNum;
    else
        options.upNum = GShowProfileParam.upNum;
    end
    
    if(GShowProfileParam.downNum == 0)
        options.downNum = GPostInvParam.downNum;
    else
        options.downNum = GShowProfileParam.downNum;
    end
    
    options.plotParam = GPlotParam;
    
    options.title = '';                                 % ����
    options.xlabel = tstr;
    options.limits = {'limit', range(1), range(2)};
    options.xlim = range;
    options.wellData = wellData;
    options.wellPos = wellPos;
    options.colormap = color;
    options.isFilt = filtCoef;
    
    options.isShowHorizon = isShowHorizon;
    
    options.firstCDP = firstCdp;                                    % ��һ��CDP��
    options.dt = GPostInvParam.dt;                                      % ����ʱ��
    options.xlabelNum = GShowProfileParam.xLabelNum;
    options.ylabelNum = GShowProfileParam.yLabelNum;
    
    options.baseTime = horizon;                     % ��׼��
    options.horizon = horizon;
    
    options.figure = {'figure', 'old'};
    options.coefShowWell = GShowProfileParam.coefShowWell;
    
    sampNum = options.upNum + options.downNum;
    
    % ��ȡ�������ݺ;�����
    profileData = profileData(GPostInvParam.upNum - options.upNum + 1 : GPostInvParam.upNum + options.downNum, :);
    
    if(~isempty(options.wellPos) && ~isempty(options.wellData))
        options.wellData = options.wellData(GPostInvParam.upNum - options.upNum + 1 : GPostInvParam.upNum + options.downNum, :);
    end
    
    % �˲�
    if options.isFilt > 0 && options.isFilt < 1
        try
            for i = 1 : sampNum
                profileData(i, :) = bsButtLowPassFilter(profileData(i, :), options.isFilt);
            end
        catch
        end
    end
    
    options.basePos = options.upNum;
    % ��ͼ�� h8��45��λ�ö���
    
    bsHorizonRestore(profileData, options);
    
end
