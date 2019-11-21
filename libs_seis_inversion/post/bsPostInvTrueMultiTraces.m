function [invResults] = bsPostInvTrueMultiTraces(GPostInvParam, inIds, crossIds, timeLine, methods)
%% inverse multiple traces
% Programmed by: Bin She (Email: bin.stepbystep@gmail.com)
% Programming dates: Nov 2019
% -------------------------------------------------------------------------
%
% Input 
% GPostInvParam     all information of the inverse task
% inIds      	inline ids to be inverted
% crossIds      crossline ids to be inverted
% timeLine      horizon information
% methods       the methods to solve the inverse task, each method is a
% struct depicting the details of the methods. For example, method.load
% indicates whether load the result from mat or segy directly.
% 
% Output
% invVals       inverted results, a cell includ
% -------------------------------------------------------------------------
    
    assert(length(inIds) == length(crossIds), 'The length of inline ids and crossline ids must be the same.');
    nMethod = size(methods, 1);
    nTrace = length(inIds);
    sampNum = GPostInvParam.upNum + GPostInvParam.downNum;
    % save the inverted results
    rangeIn = [min(inIds), max(inIds)];
    rangeCross = [min(crossIds), max(crossIds)];
    
    % horion of the whole volume
    usedTimeLine = timeLine{GPostInvParam.usedTimeLineId};
    % create folder to save the intermediate results
    try
        mkdir([GPostInvParam.modelSavePath,'/models/']);
        mkdir([GPostInvParam.modelSavePath,'/mat_results/']);
        mkdir([GPostInvParam.modelSavePath,'/sgy_results/']);
    catch
    end
    
    invResults = cell(1, nMethod);
    % horizon of given traces
    horizonTimes = bsCalcHorizonTime(usedTimeLine, inIds, crossIds, 1);
                
    for i = 1 : nMethod
        method = methods{i};
        methodName = method.name;
        matFileName = bsGetFileName('mat');
        
        res.source = [];
        
        if isfield(method, 'load')
            loadInfo = method.load;
            switch loadInfo.mode
                % load results directly
                case 'mat'
                    try
                        % from mat file
                        if isfield(loadInfo, 'fileName') && ~isempty(loadInfo.fileName)
                            load(GPostInvParam.load.fileName);
                        else
                            load(matFileName);
                        end

                        res.source = 'mat';
                    catch
                        warning('load mat file failed.');
                    end
                    
                case 'segy'
                    % from sgy file
                    poses = bsCalcT0Pos(GPostInvParam, loadInfo.segyInfo, horizonTimes);
                    [data, loadInfo.segyInfo, ~] = bsReadTracesByIds(...
                        loadInfo.fileName, ...
                        loadInfo.segyInfo, ...
                        inIds, crossIds, poses, sampNum);
                    
                    res.source = 'segy';
            end
            
        end
        
        if isempty(res.source)
            % obtain results by computing
            data = bsCallInvFcn();
            res.source = 'compution';
        end
        
        res.data = data;            % inverted results
        res.inIds = inIds;          % inverted inline ids 
        res.crossIds = crossIds;    % inverted crossline ids
        res.horizon = horizonTimes; % the horizon of inverted traces
        res.name = method.name;     % the name of this method
        
        if isfield(method, 'type')  % the type of inverted volume, IP, Seismic, VP, VS, Rho
            res.type = method.type;
        else
            res.type = 'IP';
        end
        
        if isfield(method, 'showFiltCoef')
            res.showFiltCoef = method.showFiltCoef;
        else
            res.showFiltCoef = 0;
        end
        
        invResults{i} = res;
        
        
        % save sgy file
        if isfield(method, 'isSaveSegy') && method.isSaveSegy
            segyFileName = bsGetFileName('segy');
            fprintf('Writing segy file:%s ....\n', segyFileName);
            bsWriteInvResultIntoSegyFile(res, ...
                GPostInvParam.postSeisData.segyFileName, ...
                GPostInvParam.postSeisData.segyInfo, ...
                segyFileName, ...
                GPostInvParam.upNum, ...
                GPostInvParam.dt);
            fprintf('Write segy file:%s successfully!\n', segyFileName);
        end
        
        % save mat file
        if ~isfield(method, 'isSaveMat') || method.isSaveMat
            fprintf('Writing mat file:%s...\n', matFileName);
            try
                save(matFileName, 'data', 'horizonTimes', 'inIds', 'crossIds', 'GPostInvParam', 'method');
            catch
                save(matFileName, 'data', 'horizonTimes', 'inIds', 'crossIds', 'GPostInvParam', 'method', '-v7.3');
            end
            fprintf('Write mat file:%s successfully!\n', matFileName);
        end
    end
    
    function fileName = bsGetFileName(type)
        switch type
            case 'mat'
                fileName = sprintf('%s/mat_results/Ip_%s_inline_[%d_%d]_crossline_[%d_%d].mat', ...
                    GPostInvParam.modelSavePath, methodName, rangeIn(1), rangeIn(2), rangeCross(1), rangeCross(2));
            case 'segy'
                fileName = sprintf('%s/sgy_results/Ip_%s_inline_[%d_%d]_crossline_[%d_%d].sgy', ...
                    GPostInvParam.modelSavePath, methodName, rangeIn(1), rangeIn(2), rangeCross(1), rangeCross(2));
        end
        
    end

    function data = bsCallInvFcn()
        % tackle the inverse task
        
        
        if GPostInvParam.isParallel
            
            GPostInvParam.numWorkers = bsInitParallelPool(GPostInvParam.numWorkers);

            [groupData, ~] = bsSeparateData({horizonTimes, inIds, crossIds}, GPostInvParam.numWorkers);
            
            spmd
                cdata = bsInvSubTraces(GPostInvParam, method, ...
                    groupData{1, labindex}, ...
                    groupData{2, labindex}, ...
                    groupData{3, labindex});
            end
            
            data = bsJointData(cdata);
        else
            % non-parallel computing 
            data = bsInvSubTraces(GPostInvParam, method, horizonTimes, inIds, crossIds);
        end
    end
    
end

function data = bsInvSubTraces(GPostInvParam, method, horizonTimes, inIds, crossIds)

    nTrace = length(inIds);
    sampNum = GPostInvParam.upNum + GPostInvParam.downNum;
    data = zeros(sampNum, nTrace);
    
    % obtain a preModel avoid calculating matrix G again and again.
    % see line 20 of function bsPostPrepareModel for details  
    preModel = bsPostPrepareModel(GPostInvParam, inIds(1), crossIds(1), horizonTimes(1), [], []);
            
    for iTrace = 1 : nTrace
        
        horizonTime = horizonTimes(iTrace);
        inId = inIds(iTrace);
        crossId = crossIds(iTrace);
        
        if mod(iTrace, 10) == 0
            % print progress information for each 10 traces
            fprintf('Post inversion progress information by method %s: wokder [%d] has finished %.2f%% of %d traces.\n', ...
                method.name, labindex, iTrace/nTrace*100, nTrace);
        end
        
        % create model data
        if GPostInvParam.isReadMode
            % in read mode, model is loaded from local file
            modelFileName = bsGetModelFileName(GPostInvParam.modelSavePath, inId, crossId);
            parLoad(modelFileName);
        else
            % otherwise, create the model by computing. Note that we input
            % argment preModel is a pre-calculated model, by doing this, we
            % avoid wasting time on calculating the common data of different
            % traces such as forward matrix G.
            model = bsPostPrepareModel(GPostInvParam, inId, crossId, horizonTime, [], preModel);
            if GPostInvParam.isSaveMode
                % in save mode, mode should be saved as local file
                modelFileName = bsGetModelFileName(GPostInvParam.modelSavePath, inId, crossId);
                parSave(modelFileName, model);
            end
        end
        
        [xOut, ~, ~, ~] = bsPostInv1DTrace(model.d, model.G, model.initX, model.Lb, model.Ub, method);                       

        data(:, iTrace) = exp(xOut);
    
    end

    
end

function fileName = bsGetModelFileName(modelSavePath, inId, crossId)
    % get the file name of model (to save the )
    fileName = sprintf('%s/models/model_inline_%d_crossline_%d.mat', ...
        modelSavePath, inId, crossId);

end

function [idata] = bsPostInvOneTrace(GPostInvParam, horizonTime, method, inId, crossId, preModel, isprint)

    if isprint
        fprintf('Solving the trace of inline=%d and crossline=%d by using method %s...\n', ...
            inId, crossId, method.name);
    end
    
    % create model data
    if GPostInvParam.isReadMode
        % in read mode, model is loaded from local file
        modelFileName = bsGetModelFileName(GPostInvParam.modelSavePath, inId, crossId);
        parLoad(modelFileName);
    else
        % otherwise, create the model by computing. Note that we input
        % argment preModel is a pre-calculated model, by doing this, we
        % avoid wasting time on calculating the common data of different
        % traces such as forward matrix G.
        model = bsPostPrepareModel(GPostInvParam, inId, crossId, horizonTime, [], preModel);
        if GPostInvParam.isSaveMode
            % in save mode, mode should be saved as local file
            modelFileName = bsGetModelFileName(GPostInvParam.modelSavePath, inId, crossId);
            parSave(modelFileName, model);
        end
    end

    [xOut, ~, ~, ~] = bsPostInv1DTrace(model.d, model.G, model.initX, model.Lb, model.Ub, method);                       

    idata = exp(xOut);
end
