function settingsHoggleBow = setupVariables_HoggleBow  ( settings )
% function settingsHoggleBow = setupVariables_HoggleBow  ( settings )

    %% (0) check input
    if ( nargin < 1)
        settings = [];
    end    

    %% (1) copy given settings
    settingsHoggleBow = settings;

    
    %% (2) add default values here
    
    %% OUTPUTS
    % debug outputs?
    settingsHoggleBow = addDefault( settings, 'b_verbose', false, settingsHoggleBow );  
    
    %% LOCAL FEATURE EXTRACTION    

    % fetch settings already given
    settingsLocalFeat = getFieldWithDefault ( settings, 'settingsLocalFeat', [] );    
    
    settingsLocalFeat = setupVariables_LocalFeatureExtraction ( settingsLocalFeat );
    
    % write enhanced settings to output variable
    settingsHoggleBow.settingsLocalFeat = settingsLocalFeat;

    %% INVERSION SPECIFIC
    
    % ignore outer region of patches with this size in x direction...
    % ignored if b_overlappingBlocks = false 
    settingsHoggleBow = addDefault( settings, 'i_padSizeX', 2, settingsHoggleBow );
    
    % ignore outer region of patches with this size in y direction...
    % ignored if b_overlappingBlocks = false
    settingsHoggleBow = addDefault( settings, 'i_padSizeY', 2, settingsHoggleBow );        
    
    % quantize into codebook or invert extracted features directly?
    settingsHoggleBow = addDefault( settings, 'b_quantize', true, settingsHoggleBow );       
        
    % do we want to randomly shuffle the inverted HoG block?
    settingsHoggleBow = addDefault( settings, 'b_shuffleBlocks', false, settingsHoggleBow );

    
end

function newSetting = addDefault( setting, strSettingName, value, newSetting )
  if ( ( ~isfield(setting,strSettingName))  || isempty(setting.(strSettingName) ) )
        newSetting.(strSettingName) = value;
  else
        newSetting.(strSettingName) = setting.(strSettingName);
  end  
end