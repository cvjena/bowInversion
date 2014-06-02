function out = demo2_imageInvertedAndJittered
% function out = demo2_imageInvertedAndJittered
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )

    %% setup dataset containing a single image only.
    dataset.images           = { fullfile(pwd, 'data', 'lena.png' )};
    dataset.labels           = [1];
    dataset.labels_names     = {'Lena'};
    dataset.labels_perm      = [1];
    dataset.labels_org_names = {'Lena'};
    
    
    %% compute BoW inversion
        
    % setup non-specified default values for all variables
    settingsLocalFeat = setupVariables_LocalFeatureExtraction( [] );
    
    % overlapping blocks on dense grid?
    settingsLocalFeat.b_overlappingBlocks = false;
    
    % if overlapping - which stride?
    settingsLocalFeat.i_stepSizeX         = 8;
    settingsLocalFeat.i_stepSizeY         = 8;        
    
    % size of blocks in px
    settingsLocalFeat.i_blockSizeX        = 64;
    settingsLocalFeat.i_blockSizeY        = 64;
    
    % enable progressbar
    settingsLocalFeat.b_progressbar       = true;      
        
    settingsHoggleBow.settingsLocalFeat = settingsLocalFeat;
        
    
    % jitter the image, i.e., shuffle blocks
    settingsHoggleBow.b_shuffleBlocks = true;
    
    % invert local features without quantization
    settingsHoggleBow.b_quantize      = false;

    out = hoggleBow ( [], dataset.images{1}, settingsHoggleBow );
    
    %% prepare output, if desired
    if ( nargout > 0 )
        out.dataset      = dataset;
    end
end
