function settingsLocalFeat = setupVariables_LocalFeatureExtraction  ( settings )
% function settingsLocalFeat = setupVariables_LocalFeatureExtraction  ( settings )
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )
% 
% OUTPUT: 
%   settingsLocalFeat -- struct with fields 'b_overlappingBlocks',
%                         'i_numBlocksPerDim',...
% 

    %% (0) check input
    if ( nargin < 1)
        settings = [];
    end
    
    %% (1) copy given settings    
    settingsLocalFeate = settings;

    %% (2) add default values here
    
    
    % fetch settings already given
    settingsLocalFeat = getFieldWithDefault ( settings, 'settingsLocalFeat', [] );
    
    %% OUTPUTS

    % a visual progress bar?
    settingsLocalFeat = addDefault( settings, 'b_progressbar', false, settingsLocalFeat );    
    
    
    %% LOCAL FEATURE EXTRACTION
    
    % if true, blocks are extracted with overlap and results are averaged
    % together
    settingsLocalFeat = addDefault( settings, 'b_overlappingBlocks', true, settingsLocalFeat );    
    
    % number of blocks we partition the image into... ignored if
    % b_overlappingBlocks = true
    settingsLocalFeat = addDefault( settings, 'i_numBlocksPerDim', 4, settingsLocalFeat );
    
    % size of a hog cell in x dimension...
    % ignored if b_overlappingBlocks = false
    settingsLocalFeat = addDefault( settings, 'i_blockSizeX', 64, settingsLocalFeat );
    
    % size of a hog cell in y dimension...
    % ignored if b_overlappingBlocks = false 
    settingsLocalFeat = addDefault( settings, 'i_blockSizeY', 64, settingsLocalFeat );  
    
    % stride between overlapping blocks in x direction...
    % ignored if b_overlappingBlocks = false 
    settingsLocalFeat = addDefault( settings, 'i_stepSizeX', 8, settingsLocalFeat );
    
    % stride between overlapping blocks in y direction...
    % ignored if b_overlappingBlocks = false
    settingsLocalFeat = addDefault( settings, 'i_stepSizeY', 8, settingsLocalFeat );  
    
    
    % how do we want to extract HOG features?
    featureExtractor = struct('name','DPM_HOG',           'mfunction',@extractHOG);
    settingsLocalFeat = addDefault( settings, 'featureExtractor', featureExtractor, settingsLocalFeat );
    
    % add a cache with precomputed image feature data
    dataCache = DataCache();
    dataCache.setCacheFile(fullfile(pwd, 'cache', 'hog.cache.mat') );
    settingsLocalFeat = addDefault( settings, 'dataCache', dataCache, settingsLocalFeat );
    
    % write enhanced settings to output variable
    settingsLocalFeate.settingsLocalFeat = settingsLocalFeat;
       


end


function newSetting = addDefault( setting, strSettingName, value, newSetting )
  if ( ( ~isfield(setting,strSettingName))  || isempty(setting.(strSettingName) ) )
        newSetting.(strSettingName) = value;
  else
        newSetting.(strSettingName) = setting.(strSettingName);
  end  
end