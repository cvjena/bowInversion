function codebook = computeCodebook_15Scenes( settings )
% function codebook = computeCodebook_15Scenes( settings )
% 
%  BRIEF: extract local features,compute codebook, and invert prototypes for specified
%    settings on 15Scenes dataset. Script is not super-generic, e.g., 
%    no split into train and test is included, and HoG-block sizes are fixed
%    to 64 x 64 px.

    %% (0) check input
    if ( nargin < 1)
        settings = [];
    end

    %% ( 1 ) set up variables, initialize outputs

    mySettings = setupVariables_BoWEval( settings );
    

    % load imagenet data
    disp('load 15Scenes data...');    
    
    dataset15Scenes = init15Scenes( mySettings );
    
                        
    %% ( 2 ) run codebook creation on all images
  
    % TODO split into train and test (and perhaps val )
    numImages = length( dataset15Scenes.images );
    
    % extract local features for training images
    structFeatures = extractFeatures( mySettings, dataset15Scenes,  1:numImages );

    
    %NOTE the following stuff could be encapsulated into a separte
    %file generic for varios datasets (getting images, splits, and
    %method settings)
    codebookMethod = mySettings.codebookStrategies{ 1 }.mfunction;
    codebook.prototypes = codebookMethod(structFeatures, mySettings );
    
    
    %TODO adaptive?
    myBlockSize = [64,64];
    
    codebook.invPrototypes = invertPrototypes ( codebook.prototypes, myBlockSize ) ;
end        
            