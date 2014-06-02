function precomputeCache_15Scenes()
    %call function from within the data folder to create the cache

    mySettings = setupVariables_BoWEval( [] );

    mySettings.b_overlappingBlocks = true;
    mySettings.i_blockSizeX = 64;
    mySettings.i_blockSizeY = 64;
    mySettings.i_stepSizeX  = 8;
    mySettings.i_stepSizeY  = 8;
    
    dataCache = DataCache();
    dataCache.setCacheFile('./15Scenes.hog.overlap.block64.step8.cache.mat');
    dataCache.m_bAllowOverwrite = true;
    
    mySettings.dataCache = dataCache;
    
    % load imagenet data
    disp('load 15Scenes data...');    
    dataset15Scenes = init15Scenes( mySettings );
    
    
    
    indicesImages = 1:length(dataset15Scenes.images);
    
    %extract features over all images
    extractFeatures( mySettings, dataset15Scenes, indicesImages );
    
    disp('Save & Close Cache');
    dataCache.closeCache();
    disp('Done');
end
