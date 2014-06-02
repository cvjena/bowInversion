function dataset = init15Scenes( settings )
% function dataset = init15Scenes( settings )
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )
% 
% BRIEF:
%    Set up a dataset struct containing filenames to training and test
%    images of the 15 scenes dataset.
% 
% INPUT:
%    settings -- struct, optional, contains fields such as 'f_fnFilelist',
%                'i_numImgPerClass', 'classIndicesToUse'. Unspecified
%                fields are set to default values.
% 
% OUTPUT:
%    dataset  -- struct with fields 'images', 'labels', 'labels_perm',
%                'labels_org_names'


    %% fetch inputs
    if ( nargin < 1)
        settings = [];
    end

    %% try to read filelist
    
    f_fnFilelist = getFieldWithDefault ( settings, 'f_fnFilelist', '15Scenes.txt' );
    
    try 
        fileListID = fopen( f_fnFilelist );       

        fileLists = textscan(fileListID, '%s');
        fclose(fileListID);
    catch err
        disp ('Error while reading filelist... Aborting!')
    end

    fileLists = fileLists{1};
    
    


    % note: if noImgPerClass == -1 , then use all images available
    i_numImgPerClass  = getFieldWithDefault ( settings, 'i_numImgPerClass', 100 );
    
    classIndicesToUse = getFieldWithDefault ( settings, 'classIndicesToUse', 1:15 );
    
    
    %% read images for specified classes 
    dataset.images = [];
    dataset.labels = [];    
    
    labels_names_origOrder =             { 'bedroom',      'suburb',      'industrial',...
                                           'kitchen',      'living room', 'coast',...
                                           'forest',       'highway',     'inside city',...
                                           'mountain',     'open country','street',...
                                           'tall building','office',      'store' };
    [dataset.labels_names, dataset.labels_perm] = sort ( labels_names_origOrder );
    
    dataset.labels_org_names           = { 'bedroom',        'CALsuburb',      'industrial', ...
                                           'kitchen',        'livingroom',     'MITcoast', ...
                                           'MITforest',      'MIThighway',     'MITinsidecity', ...
                                           'MITmountain',    'MITopencountry', 'MITstreet', ...
                                           'MITtallbuilding','PARoffice',      'store' };

    i_noClasses = size ( classIndicesToUse , 2 );
    
    try 
        for clIdx = 1:i_noClasses
            disp(fileLists{ classIndicesToUse(clIdx) });
            classFileListID = fopen( fileLists{ classIndicesToUse(clIdx) } );
            classFileList = textscan(classFileListID, '%s');
            fclose(classFileListID);
            
            classFileList = classFileList{1};
            
            if i_numImgPerClass == -1  % use all images available
                % append file names of new category
                dataset.images = [ dataset.images; classFileList ];
            
                % append class label of new category
                dataset.labels = [ dataset.labels  classIndicesToUse(clIdx)*ones(1,length(classFileList) ) ] ;
            
            else % only use subset of data
                
                % append file names of new category
                dataset.images = [ dataset.images; classFileList(1:i_numImgPerClass) ];
            
                % append class label of new category
                dataset.labels = [ dataset.labels  classIndicesToUse(clIdx)*ones(1,i_numImgPerClass ) ] ;
            end
        end
    catch  err
        error('Error while reading filenames of 15 Scenes dataset - check that your filename file is up to date!');
    end
    
end