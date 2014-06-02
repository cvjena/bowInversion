function settingsBoWEval = setupVariables_BoWEval  ( settings )
% function settingsBoWEval = setupVariables_BoWEval  ( settings )
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )
% 
% OUTPUT: 
%   settingsBoWEval -- struct with fields 'b_verbose', 'settingsLocalFeat',
%                      'settingsClassification', 'settingsClustering', 'settingsEval'
% 

    %% (0) check input
    if ( nargin < 1)
        settings = [];
    end
    
    %% (1) copy given settings    
    settingsBoWEval = settings;

    %% (2) add default values here
    
    %% OUTPUTS
    % debug outputs?
    settingsBoWEval = addDefault( settings, 'b_verbose', false, settingsBoWEval );
    
    settingsBoWEval = addDefault( settings, 'b_progressbar', false, settingsBoWEval );
    
    %% LOCAL FEATURE EXTRACTION

    % fetch settings already given
    settingsLocalFeat = getFieldWithDefault ( settings, 'settingsLocalFeat', [] );    
    
    settingsLocalFeat = setupVariables_LocalFeatureExtraction ( settingsLocalFeat );
    
    % write enhanced settings to output variable
    settingsBoWEval.settingsLocalFeat = settingsLocalFeat;
    
    %% CLASSIFICATION
    
    % fetch settings already given
    settingsClassification = getFieldWithDefault ( settings, 'settingsClassification', [] );
    
    % SVM settings for train and prediction
    %..train    
    %-q quiet
    sSettingsString = sprintf(' -q');%, m_ParamQ, m_ParamS, m_ParamC, m_ParamB);
    settingsClassification = addDefault( settingsClassification, 's_SvmSettingsTrain', sSettingsString, settingsClassification );
    %..predict
    sSettingsString = sprintf(' -q');%, m_ParamQ, m_ParamS, m_ParamC, m_ParamB);
    settingsClassification = addDefault( settingsClassification, 's_SvmSettingsPredict', sSettingsString, settingsClassification );
    
    % expansion of features to approximate better kernels than the linear
    % one
    settingsClassification = addDefault( settingsClassification, 's_svm_Kernel', 'linear', settingsClassification );
%     settingsClassification = addDefault( settings, 's_svm_Kernel', 'chi-squared', settingsClassification );
%     settingsClassification = addDefault( settings, 'i_homkermap_n', 3, settingsClassification );
%     settingsClassification = addDefault( settings, 'd_homkermap_gamma', 0.5, settingsClassification );

    % write enhanced settings to output variable
    settingsBoWEval.settingsClassification = settingsClassification;
    
    %% CLUSTERING / CODEBOOK GENERATION
    
    % fetch settings already given
    settingsClustering = getFieldWithDefault ( settings, 'settingsClustering', [] );    
    
    settingsClustering = setupVariables_Clustering ( settingsClustering );
    
    % write enhanced settings to output variable
    settingsBoWEval.settingsClustering = settingsClustering;    
        
    
    %% EVALUTION STUFF
    
    % fetch settings already given
    settingsEval = getFieldWithDefault ( settings, 'settingsEval', [] );
    
    

    % how many different train-test-splits do we want to
    % average over?
    settingsEval = addDefault( settingsEval, 'i_numRandomSplits', 5, settingsEval );   
    
    
    % write enhanced settings to output variable
    settingsBoWEval.settingsEval = settingsEval;

    %% DATASET
    % fetch settings already given
    settingsDataset = getFieldWithDefault ( settings, 'settingsDataset', [] );   
    
    % where is the filelist file?
    settingsDataset = addDefault( settingsDataset, 'f_fnFilelist', 'data/15Scenes.txt', settingsDataset );
    
    % how many images per class for training+testing ?
    settingsDataset = addDefault( settingsDataset, 'i_numImgPerClass', 100, settingsDataset );
    
    % which class numbers to use?
    settingsDataset = addDefault( settingsDataset, 'classIndicesToUse', 1:15, settingsDataset );
    
        
    % how to split the loaded dataset into train and test datasets?
%     splitTrainTest = struct('name','percentage split into disjunct sets', 'mfunction',@splitTrainTest_Percentage);
   splitTrainTest = struct('name','take N images per class for train','i_TrainSplitImagesPerClass',4, 'mfunction',@splitTrainTest_FixedNumberPerClass);
    settingsDataset = addDefault( settingsDataset, 'splitTrainTest', splitTrainTest, settingsDataset );    
    
    % percentage  (0..1) of chosen images for train
    settingsDataset = addDefault( settingsDataset, 'f_numTrainImagesPercentage', 0.8, settingsDataset );      
        
    % write enhanced settings to output variable
    settingsBoWEval.settingsDataset = settingsDataset;    


end


function newSetting = addDefault( setting, strSettingName, value, newSetting )
  if ( ( ~isfield(setting,strSettingName))  || isempty(setting.(strSettingName) ) )
        newSetting.(strSettingName) = value;
  else
        newSetting.(strSettingName) = setting.(strSettingName);
  end  
end