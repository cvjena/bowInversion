function settingsClustering = setupVariables_Clustering  ( settings )
% function settingsClustering = setupVariables_Clustering  ( settings )
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )
% 
% OUTPUT: 
%   settingsClustering -- struct with fields 'i_numClusters',
%                       'codebookStrategies', ...
% 

    %% (0) check input
    if ( nargin < 1)
        settings = [];
    end
    
    %% (1) copy given settings    
    settingsClustering = settings;

    %% (2) add default values here
    
    %% OUTPUTS    
    % debug outputs?
    settingsClustering = addDefault( settings, 'b_verbose', false, settingsClustering );    
    
    %% CLUSTERING / CODEBOOK GENERATION
    
        
    % number of clusters to build a codebook
    settingsClustering = addDefault( settings, 'i_numClusters', 128, settingsClustering );
    

    
    % how to build codebooks
    ii=1;
    codebookStrategies{ii} = struct('name','k-Means',           'mfunction',@generateCodebookKmeans);ii=ii+1;
    codebookStrategies{ii} = struct('name','random Selection',           'mfunction',@generateCodebookRandomSelection);ii=ii+1;
%     codebookStrategies{ii} = struct('name','random Uniform Sampled', 'mfunction',@generateCodebookRandomCreateUniform);ii=ii+1;
%     codebookStrategies{ii} = struct('name','random Distribution Sampled',    'mfunction',@generateCodebookRandomCreateProb);ii=ii+1;
    settingsClustering = addDefault( settings, 'codebookStrategies', codebookStrategies, settingsClustering );

    % for k-Means: perform a subselection of samples (reduce data amount
    % when clustering: (disabling for value -1)
    settingsClustering = addDefault( settings, 'codebook_kmeans_sample_subselection', 100000, settingsClustering );
    
    % histogram generation method
    histogramPooling = struct('name', 'pooling over image', 'mfunction',@histogramPoolingOverImage);
    settingsClustering  = addDefault( settings, 'histogramPooling', histogramPooling, settingsClustering );    
        

end


function newSetting = addDefault( setting, strSettingName, value, newSetting )
  if ( ( ~isfield(setting,strSettingName))  || isempty(setting.(strSettingName) ) )
        newSetting.(strSettingName) = value;
  else
        newSetting.(strSettingName) = setting.(strSettingName);
  end  
end