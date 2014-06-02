function out = eval_visualizeHoggleBow_multCB ( codebooks, s_imgfn, settings )
% function out = eval_visualizeHoggleBow_multCB ( codebooks, s_imgfn, settings )
%
%  BRIEF: compute HoggleBoW for a given image and several pre-defined
%  codebooks. Useful to visually compare HoggleBow abilities for
%  different clustering techniques or different codebook sizes

    
    
    settingsHoggleBow = getFieldWithDefault ( settings, 'settingsHoggleBow', [] );
    settingsHoggleBow.i_blockSizeX = 64;
    settingsHoggleBow.i_blockSizeY = 64;      
    
    
    settingsHoggleBow.b_quantize = true;    
    for i = size(codebooks,2):-1:1        
        hoggleBowImgs{i+1} = hoggleBow( codebooks{i}, s_imgfn , settingsHoggleBow );
    end
    
    % also compute the inverted image without vector quantization    
    b_alsoWithoutVQ = getFieldWithDefault ( settings, 'b_alsoWithoutVQ', false);
    if ( b_alsoWithoutVQ )
        settingsHoggleBow.b_quantize = false;    
        hoggleBowImgs{1} = hoggleBow( [], s_imgfn , settingsHoggleBow );
    end
    

    
    %% output desired?
    if ( nargout > 0 )
        out = hoggleBowImgs;
    end
    
    %% saving of results desired?
    if ( getFieldWithDefault ( settings, 'b_saveImages', false) )
        s_destinationPrefix = getFieldWithDefault ( settings, 's_destinationPrefix', '/tmp/');
        
        idxSlash = strfind ( s_imgfn, '/' );
        idxDot   = strfind ( s_imgfn, '.' );
        
        
        className = s_imgfn( (idxSlash( (size(idxSlash,2)-1))+1):(idxSlash(size(idxSlash,2))-1) );
        imgName   = s_imgfn( (idxSlash( (size(idxSlash,2)))+1): idxDot(size(idxDot,2))-1 );
        
        for i = size(codebooks,2):-1:1
            
            i_numberPrototypes = size(codebooks{i}.prototypes,1);
            s_destinationDir = sprintf( '%s%05d/%s/', s_destinationPrefix, i_numberPrototypes, className );
            
            % check that destination folder is valid
            if ( ~exist(s_destinationDir, 'dir') )
                mkdir ( s_destinationDir );
            end
            
            % write image
            s_destination = sprintf( '%s%s.png', s_destinationDir, imgName );
            imwrite ( hoggleBowImgs{i+1}.imgHoggleBow,  s_destination ) ;
            
        end
        
        if ( b_alsoWithoutVQ )
            idxNoVQ = 1;
        else
            idxNoVQ = 0;
        end
        
        for i = 1:idxNoVQ % only a single version without vector quantization

            s_destinationDir = sprintf( '%snoVQ/%s/', s_destinationPrefix, className );

            % check that destination folder is valid
            if ( ~exist(s_destinationDir, 'dir') )
                mkdir ( s_destinationDir );
            end

            % write image
            s_destination = sprintf( '%s%s.png', s_destinationDir, imgName );
            imwrite ( hoggleBowImgs{1}.imgHoggleBow,  s_destination ) ;

        end    
    end
end