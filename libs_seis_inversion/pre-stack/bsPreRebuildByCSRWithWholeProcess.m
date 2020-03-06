function outResult = bsPreRebuildByCSRWithWholeProcess(GInvParam, timeLine, wellLogs, method, invResult, name, varargin)

    p = inputParser;
    GTrainDICParam = bsCreateGTrainDICParam(...
        'csr', ...
        'title', 'high_freq', ...
        'sizeAtom', 90, ...
        'sparsity', 5, ...
        'iterNum', 5, ...
        'nAtom', 4000, ...
        'filtCoef', 1);
    

    addParameter(p, 'mode', 'full_freq');
    addParameter(p, 'wellFiltCoef', 0.1);
    addParameter(p, 'lowCut', 0.1);
    addParameter(p, 'highCut', 1);
    addParameter(p, 'sparsity', 5);
    addParameter(p, 'gamma', 0.5);
    addParameter(p, 'title', 'high_freq_rebuit');
    addParameter(p, 'trainNum', length(wellLogs));
    addParameter(p, 'exception', []);
    addParameter(p, 'mustInclude', []);
    addParameter(p, 'GTrainDICParam', GTrainDICParam);
    
    p.parse(varargin{:});  
    options = p.Results;
    GTrainDICParam = options.GTrainDICParam;
    GTrainDICParam.filtCoef = 1;
    
    switch options.mode
        case 'full_freq'
            GTrainDICParam.isNormalize = 0;
            DICTitle = sprintf('%s_isNormal_%d', ...
                GTrainDICParam.title, GTrainDICParam.isNormalize);
        case 'low_high'
            GTrainDICParam.isNormalize = 1;
            options.gamma = 1;
            DICTitle = sprintf('%s_isNormal_%d_lowCut_%.2f', ...
                GTrainDICParam.title, GTrainDICParam.isNormalize, options.lowCut);
    end
    
    wells = cell2mat(wellLogs);
    wellInIds = [wells.inline];
    wellCrossIds = [wells.crossline];

    % inverse a profile
    [~, ~, GInvParamWell] = bsBuildInitModel(GInvParam, timeLine, wellLogs, ...
        'title', 'all_wells', ...
        'inIds', wellInIds, ...
        'filtCoef', options.wellFiltCoef, ...
        'crossIds', wellCrossIds ...
    );

    fprintf('�������в⾮��...\n');
    wellInvResults = bsPreInvTrueMultiTraces(GInvParamWell, wellInIds, wellCrossIds, timeLine, {method});

    set_diff = setdiff(1:length(wellInIds), options.exception);
    train_ids = bsRandSeq(set_diff, options.trainNum);
    train_ids = unique([train_ids, options.mustInclude]);
    outResult = bsSetFields(invResult, {'name', name});
    
    %% ��ǰ����������
    for i = 1 : 3
        switch i
            case 1
                dataIndex = GInvParam.indexInWellData.vp;
                GTrainDICParam.title = ['vp_', DICTitle];
            case 2
                dataIndex = GInvParam.indexInWellData.vs;
                GTrainDICParam.title = ['vs_', DICTitle];
            case 3
                dataIndex = GInvParam.indexInWellData.rho;
                GTrainDICParam.title = ['rho_', DICTitle];
        end
        
        [outLogs] = bsGetPairOfInvAndWell(GInvParam, timeLine, wellLogs, wellInvResults{1}.data{i}, dataIndex, options);
        fprintf('ѵ�������ֵ���...\n');
        [DIC, train_ids, rangeCoef] = bsTrainDics(GTrainDICParam, outLogs, train_ids, ...
            [ 1, 2], GTrainDICParam.isRebuild);
        GInvWellSparse = bsCreateGSparseInvParam(DIC, 'csr', ...
        'sparsity', options.sparsity, ...
        'stride', 1);
    
        options.rangeCoef = rangeCoef;
        [testData] = bsPostReBuildByCSR(GInvParam, GInvWellSparse, wellInvResults{1}.data{i}, options);
    
%         figure; plot(testData(:, 1), 'r', 'linewidth', 2); hold on; 
%         plot(outLogs{1}.wellLog(:, 2), 'k', 'linewidth', 2); 
%         plot(outLogs{1}.wellLog(:, 1), 'b', 'linewidth', 2);
%         legend('�ع����', 'ʵ�ʲ⾮', '���ݽ��', 'fontsize', 11);
%         set(gcf, 'position', [261   558   979   420]);
%         bsShowFFTResultsComparison(GInvParam.dt, [outLogs{1}.wellLog, testData(:, 1)], {'���ݽ��', 'ʵ�ʲ⾮', '�ع����'});

        % �����ֵ�ϡ���ع�
        fprintf('�����ֵ�ϡ���ع�: �ο�����Ϊ���ݽ��...\n');
        [outputData] = bsPostReBuildByCSR(GInvParam, GInvWellSparse, invResult.data{i}, options);

        outResult.data{i} = outputData;

    end
    
    bsWriteInvResultsIntoSegyFiles(GInvParam, {outResult}, options.title);

end