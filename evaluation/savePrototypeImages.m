function savePrototypeImages ( codebook, settings )
% function savePrototypeImages ( codebook, settings )
%
% author: Alexander Freytag
% date  : 28-05-2014 ( dd-mm-yyyy )
% 
%  BRIEF: Given a codebook with inverted prototypes, images are visualized
%         and stored centrally.

    %% (0) check input
    
    i_numberPrototypes = size(codebook.invPrototypes,2);
    
    if ( ~isfield(settings,'s_destDir') || ...
            isempty(settings.s_destDir)  )
        s_destDir = sprintf( './%i/', i_numberPrototypes );
    else
        s_destDir = sprintf( '%s%i/', settings.s_destDir, i_numberPrototypes );
    end
    
    % check for existing of destination folder
    if ( exist(s_destDir, 'dir') == 0 )
        mkdir ( s_destDir );
    end  

    %% ( 1 ) set up variables
    
    % did we specify which prototypes to save only?
    if  (~isfield(settings, 'idxToSave') || isempty(settings.idxToSave) )
        idxToSave = 1:size(codebook.invPrototypes,2);
    else
        idxToSave = settings.idxToSave;
    end

    
    %% (2) save inverted prototypes
    for i = 1:size(idxToSave,2)
        
        figProto=figure;
        imagesc(codebook.invPrototypes{ idxToSave(i) })
        axis image;
        axis off;
        colormap gray;    

        s_fn_proto = sprintf('%sproto%i.eps',s_destDir,idxToSave(i));
        saveWithoutWhiteBorder(figProto, s_fn_proto);
        close ( figProto );
        
    end
    
end
