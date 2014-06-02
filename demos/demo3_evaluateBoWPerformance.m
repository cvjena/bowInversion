function out = demo3_evaluateBoWPerformance
% function out = demo3_evaluateBoWPerformance
% 
% author: Alexander Freytag
% date  : 28-05-2014 ( dd-mm-yyyy )


    %% configuration
    
    % setup non-specified default values for all variables
    settingsLocalFeat = setupVariables_LocalFeatureExtraction( [] );
    
    % overlapping blocks on dense grid?
    settingsLocalFeat.b_overlappingBlocks = true;
    
    % if overlapping - which stride?
    settingsLocalFeat.i_stepSizeX         = 8;
    settingsLocalFeat.i_stepSizeY         = 8;        
    
    % size of blocks in px
    settingsLocalFeat.i_blockSizeX        = 64;
    settingsLocalFeat.i_blockSizeY        = 64;

    % disable progressbar to make it runnable without GUI enviroment
    settingsLocalFeat.b_progressbar       = false;
    
    % where to cache features on disk?
    dataCache = DataCache();
    dataCache.setCacheFile( fullfile(pwd, 'demos', 'cache.mat' ));
    dataCache.m_bAllowOverwrite = true;
    
    settingsLocalFeat.dataCache = dataCache;    
    
    settings.settingsLocalFeat = settingsLocalFeat;

    %% dataset - evaluate on 5 classes only in this demo file
    
    % directory for the 15 Scenes dataset
    %settings.settingsDataset.f_fnFilelist = 'data/15Scenes.txt';
    % randomly pick 10 images per class
    settings.settingsDataset.i_numImgPerClass = 10;
    % work on the first 5 classes only
    settings.settingsDataset.classIndicesToUse = [1:5];
    
    % randomly pick 4 out of 10 per class for training
    settings.settingsDataset.splitTrainTest = struct('name','take N images per class for train', ...
        'i_TrainSplitImagesPerClass',4, 'mfunction',@splitTrainTest_FixedNumberPerClass);
    
    %% codebooks to compare - use only two strategies here
    % how to build codebooks
    ii=1;
    codebookStrategies{ii} = struct('name','k-Means',           'mfunction',@generateCodebookKmeans);ii=ii+1;
    codebookStrategies{ii} = struct('name','random Selection',           'mfunction',@generateCodebookRandomSelection);ii=ii+1;
    settingsClustering                    =  [];
    settingsClustering.codebookStrategies = codebookStrategies;    
    
    settings.settingsClustering = settingsClustering;
    
    %% evaluation settings
    % give some interesting outputs
    settings.b_verbose = true;
    % compute results for 5 random runs
    settings.settingsEval.i_numRandomSplits = 5;

    %% call the main evaluation script
    
    %NOTE
    % since we compute local features for quite a lot of images in a dense
    % fashion, this call could be memory consuming. (>8GB RAM)
    structResults = bowComparison_15Scenes( settings );
    
    %% small evaluation
    
    % compute mean accuracy of both codebook generation methods
    meanARR = mean ( structResults.perf_values_arr, 2 );
    
    % create new figure handle to display results
    hFig = figure;
    
    bar( meanARR );
    
    s_legends = {};
    for i=1:length(codebookStrategies)
        s_legends = [ s_legends,  codebookStrategies{i}.name];
    end
    
    xlabel('Codebook technique');
    
    %
    set(gca,'xticklabel', s_legends, 'fontsize',10 );
    xlim([0.45,length(codebookStrategies)+0.55])
    
    ylabel('ARR');    
    
    % wait for user input
    pause
    % close figure
    close(hFig);

    
    %% prepare output, if desired
    if ( nargout > 0 )
        out.structResults      = structResults;
    end
end
