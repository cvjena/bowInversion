function precomputeCache_15Scenes_full()
    %call function from within the data folder to create the cache

    mySettings = setupVariables_BoWEval( [] );

    mySettings.b_overlappingBlocks = true;
    mySettings.i_blockSizeX = 64;
    mySettings.i_blockSizeY = 64;
    mySettings.i_stepSizeX  = 8;
    mySettings.i_stepSizeY  = 8;
    
    dataCache = DataCachePerFile();
    dataCache.setCacheFile('./15Scenes.full.hog.overlap.block64.step8.cache.mat');
    dataCache.m_bAllowOverwrite = true;
    
    mySettings.dataCache = dataCache;
    
    % load imagenet data
    disp('load 15Scenes data...');    
    mySettings.noImgPerClass = -1; % use all images
    dataset15Scenes = init15Scenes( mySettings );
    
    dataCache.openCacheFile();
    
    indicesImages = 1:length(dataset15Scenes.images);
    
    %extract features over all images
    extractFeatures( mySettings, dataset15Scenes, indicesImages );
    
    disp('Save & Close Cache');
    dataCache.closeCache();
    disp('Done');
end
