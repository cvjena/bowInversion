function out = demo1_inversionPipeline
% function out = demo1_inversionPipeline
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )

    %% setup dataset containing a single image only.
    dataset.images           = { fullfile(pwd, 'data', 'lena.png' )};
    dataset.labels           = [1];
    dataset.labels_names     = {'Lena'};
    dataset.labels_perm      = [1];
    dataset.labels_org_names = {'Lena'};
    
    
    %% extract features
    
    indicesImages = 1;
    
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
    
    % enable progressbar
    settingsLocalFeat.b_progressbar       = true;    
    
    % where to cache features on disk?
    dataCache = DataCache();
    dataCache.setCacheFile( fullfile(pwd, 'demos', 'cache.mat' ));
    dataCache.m_bAllowOverwrite = true;
    
    settingsLocalFeat.dataCache = dataCache;
    
    
    % call feature extraction
    myFeatures = extractFeatures( settingsLocalFeat, dataset, indicesImages );   
    
    %% compute codebook
    
    settingsClustering = setupVariables_Clustering ( [] );
    
    codebookMethod      = settingsClustering.codebookStrategies{ 1 }.mfunction;
    codebook.prototypes = codebookMethod(myFeatures, settingsClustering );
    
    %% invert computed prototypes
    myBlockSize = [settingsLocalFeat.i_blockSizeY, settingsLocalFeat.i_blockSizeX];
    
    codebook.invPrototypes = invertPrototypes ( codebook.prototypes, myBlockSize ) ;    
    
    %% compute BoW inversion
    settingsHoggleBow.settingsLocalFeat = settingsLocalFeat;

    out = hoggleBow ( codebook, dataset.images{1}, settingsHoggleBow );
    
    %% prepare output, if desired
    if ( nargout > 0 )
        out.dataset      = dataset;
        out.myFeatures   = myFeatures;
        out.codebook     = codebook;
    end
end
