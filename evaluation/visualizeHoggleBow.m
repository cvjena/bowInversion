function out = visualizeHoggleBow ( codebook, settings, s_imgfn )
% function out = visualizeHoggleBow ( codebook, settings, s_imgfn )
%
%  BRIEF: compute HoggleBoW for a given image with and without vector
%  quantization into a pre-defined codebook. Save inverted top-3 prototypes
%  as well.

    %might be empty if only images without vector quantization are needed
    if ( ~isempty(codebook) )
        i_numberPrototypes = size(codebook.prototypes,1);
    end
    
    if ( nargin < 2 ) 
        settings = [];
    end
    
    b_verbose = getFieldWithDefault ( settings, 'b_verbose', true );
    
    settings.settings_hoggleBow.i_blockSizeX = 64;
    settings.settings_hoggleBow.i_blockSizeY = 64;     
    
    
    % general visualizations
    b_showImages = getFieldWithDefault( settings, 'b_showImages', false );
    b_saveImages = getFieldWithDefault( settings, 'b_saveImages', false );    
    
    if ( b_saveImages ) 
        % setup a nice image filename for saving the results lateron meaningfully
        if ( nargin < 3) 
            s_imgfn = '';
        end
        if ( ~isempty(s_imgfn) )
            idxSlash = strfind ( s_imgfn, '/' );
            idxDot = strfind ( s_imgfn, '.' );

            idx2ndLastSlash = idxSlash ( size(idxSlash,2)-1 );
            idxLastSlash = idxSlash ( size(idxSlash,2) );

            idxLastDot = idxDot ( size(idxDot,2) );

            try
                s_className =  s_imgfn( (idx2ndLastSlash+1):(idxLastSlash-1) );
            catch err
            end

            s_imgName =  s_imgfn( (idxLastSlash+1):(idxLastDot-1) );
        else
            s_imgName = '';
            s_className = '';
        end

        if ( isempty(s_imgName) )
            s_imgName = 'img';
        end

        if ( isempty(s_className) )
            s_className = 'imgHoggleBow';
        end    

        if ( ~isfield(settings,'s_destDir') || ...
                isempty(settings.s_destDir)  )
            s_destDir = sprintf('./%s/', s_className);
        else
            s_destDir = sprintf('%s%s/', settings.s_destDir, s_className);
        end   
        
        % check for existing of destination folder
        if ( ~exist(s_destDir, 'dir') )
            mkdir ( s_destDir );
        end           
    end
    
    % prototype visualizations
    b_showPrototypes         = getFieldWithDefault ( settings, 'b_showPrototypes', false );
    i_numberPrototypesToShow = getFieldWithDefault ( settings, 'i_numberPrototypesToShow', 3 );


        
    
    %% without quantization
    if ( getFieldWithDefault ( settings,'b_computeImageWithoutQuantization', true ) )
        if ( b_verbose )
            fprintf('***Compute image without quantizing local features...\n\n')
         end

        settings.settings_hoggleBow.b_quantize = false;

        imgNotVQ  = hoggleBow( codebook, s_imgfn , settings.settings_hoggleBow );
        
        if ( b_showImages ) 
            fig_notVQ = figure;
            imagesc(imgNotVQ.imgHoggleBow)
            axis image;
            axis off;
            colormap gray;
        end

        if ( b_saveImages )
            s_fn_notVQ = sprintf('%s%s_notVQ.eps',s_destDir,s_imgName);
            saveWithoutWhiteBorder(fig_notVQ,s_fn_notVQ);
        end
    end

    %% with quantization
    if ( getFieldWithDefault ( settings,'b_computeImageWithQuantization', true ) )
        if ( b_verbose )
            fprintf('*** Compute image with quantizing local features...\n\n')
        end

        settings.settings_hoggleBow.b_quantize = true;

        imgVQ = hoggleBow( codebook, s_imgfn , settings.settings_hoggleBow );

        if ( b_showImages ) 
            fig_VQ = figure;
            colormap gray;
            imagesc(imgVQ.imgHoggleBow)
            axis image;
            axis off;
        end

        if ( b_saveImages )
            s_fn_VQ = sprintf('%s%s_%i_VQ.eps',s_destDir, s_imgName, i_numberPrototypes );
            saveWithoutWhiteBorder(fig_VQ,s_fn_VQ);
        end
        
        %% histogram after pooling of quantized features
        if ( b_verbose )
            fprintf('*** Compute image showing pooled histogram and prototypes...\n\n')
        end
        imgHist = imgVQ.histogram;

        if ( b_showImages ) 
            fig_Hist = figure;
            bar(imgHist, 'r');

            xlim([0 i_numberPrototypes+1]);
            xlabel('Index of Prototype');
            set(get(gca,'XLabel'), 'FontSize', 16);
            ylabel('Frequency');
            set(get(gca,'YLabel'), 'FontSize', 16);
        end

        if ( b_saveImages )
            s_fn_histo = sprintf('%s%s_%i_histo.eps',s_destDir, s_imgName, i_numberPrototypes);
            saveWithoutWhiteBorder(fig_Hist, s_fn_histo);
        end        
    end   

    % close images savely
    if ( getFieldWithDefault ( settings, 'b_closeImages', true ) )

        if ( exist( 'fig_notVQ', 'var') )
            try
                close ( fig_notVQ );
            catch err
            end
        end
        
        if ( exist( 'fig_VQ', 'var') )
            try
                close ( fig_VQ );
            catch err
            end
        end
        
        if ( exist( 'fig_Hist', 'var') )
            try
                close ( fig_Hist );
            catch err
            end
        end
    end    
    
    %% visualize prototypes
    if ( b_showPrototypes )
        [~,perm] = sort(imgHist,'descend');

        for i=1:i_numberPrototypesToShow
            figProto=figure;
            imagesc(codebook.invPrototypes{perm(i)})
            axis image;
            axis off;
            colormap gray;    

            if ( b_saveImages )
                s_fn_proto = sprintf('%s%s_%i_proto%i_idx%i.eps',s_destDir, s_imgName, i_numberPrototypes, i, perm(i));
                saveWithoutWhiteBorder(figProto, s_fn_proto);
            end
            close ( figProto );
        end
    end
    
    
    %% output desired?
    if ( nargout > 0 )
        if ( exist ( 'imgVQ', 'var' ))
            out = imgVQ.imgHoggleBow;
        elseif  ( exist ( 'imgNotVQ', 'var' ))
            out = imgNotVQ;
        else
            out = [];
        end
    end    
    
end
