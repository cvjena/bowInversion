function out = hoggleBow ( codebook, s_imgfn, settings)
% function out = hoggleBow ( codebook, s_imgfn, settings)
%
% BRIEF: Compute hog-arrays from small local image blocks, quantize them to the nearest
% prototype of a pre-computed codebook, invert features of prototypes (find 
% image patches where those features could have been computed from)
% and stick the results together.
%
%   The function accepts the following options:
%   INPUT: 
%        codebook            --   BoW codebook used for vector quantization
%        s_imgfn             --   optional, file to the image being
%                                 processed
%        settings            --   several settings (see setupVariables_HoggleBow.m) 
%
%
%   OUTPUT: 
%        out                 --   optional, the hoggle-image computed from 
%                                 locale features and possible permutations
% 

    %% (0) check input
    
    if ( ( nargin < 2) || isempty(s_imgfn) )
        s_imgfn = 'data/lena.png';
    end
    
    if ( nargin < 3)
        settings = [];
    end
   
    % default variable settings
    settingsHoggleBow = setupVariables_HoggleBow ( settings );
    
    % read given image
    img = imread ( s_imgfn); 
    
    if size(img,1) ~= 512 || size(img,2) ~= 512
        sizeMax = 512; %max( size(img) );
        img = imresize( img, [sizeMax,sizeMax], 'bilinear'); %linear interpolation
    end    
    
    % convert gray image into color image
    if (  length(size(img)) == 2 )
        img = repmat(img,[1,1,3]);
    end
    
    [height,width,~] = size(img);
    
   
    if ( settingsHoggleBow.settingsLocalFeat.b_overlappingBlocks )
        % overlapping blocks - but no permutations...
        i_blockSizeX = settingsHoggleBow.settingsLocalFeat.i_blockSizeX;
        i_blockSizeY =  settingsHoggleBow.settingsLocalFeat.i_blockSizeY;

        myBlockSize = [i_blockSizeY, i_blockSizeX];        
    else
        % no overlapping blocks - but possible permutations...
        i_blockSizeX = floor( width  / settingsHoggleBow.settingsLocalFeat.i_numBlocksPerDim );
        i_blockSizeY = floor( height / settingsHoggleBow.settingsLocalFeat.i_numBlocksPerDim );

        i_numBlocksPerDim = settingsHoggleBow.settingsLocalFeat.i_numBlocksPerDim;
        
        myBlockSize = [i_blockSizeY, i_blockSizeX];
    end
    

    %% Invert codebook prototypes if not already done previously
    if ( ~isempty(codebook) )
        % pre-compute the inverted prototypes, i.e., the patches the prototypes
        % are most likely extracted from
        if ( ~isstruct( codebook ) || ~isfield(codebook, 'invPrototypes' ) )
            invPrototypes = invertPrototypes ( codebook, myBlockSize ) ;
            prototypes    = codebook;
        else
            invPrototypes = codebook.invPrototypes;
            prototypes    = codebook.prototypes;

            % check that inverted prototypes are of correct size
            if ( ~isequal( size( invPrototypes{ 1 } ) , myBlockSize ) )

                invPrototypes = cellfun( @(imgToResize) imresize(imgToResize,myBlockSize),...
                         invPrototypes, ...
                         'UniformOutput', false...
                    );
            end
        end
    end


    %% Compute inverted image from inverted local (quantized) features
    if ( settingsHoggleBow.settingsLocalFeat.b_overlappingBlocks )
        % overlapping blocks - but no permutations... 
        
        imgPad    = padarray(img,[i_blockSizeX/2,i_blockSizeY/2]);
        widthPad  = width + i_blockSizeX;
        heightPad = height + i_blockSizeY;        

        % init output value
        imgHoggleBow = zeros( heightPad, widthPad );
        
        % count how many blocks have been used for every pixel to average 
        imgCnt = zeros( heightPad, widthPad );
        
        i_stepSizeX = settingsHoggleBow.settingsLocalFeat.i_stepSizeX;
        i_stepSizeY = settingsHoggleBow.settingsLocalFeat.i_stepSizeY;
        
        i_padSizeX  = settingsHoggleBow.i_padSizeX;
        i_padSizeY  = settingsHoggleBow.i_padSizeY;  
        
        myPadBlockSize = [ i_blockSizeY + i_padSizeY, i_blockSizeX + i_padSizeX];
        
        i_loopEndY = (heightPad-i_blockSizeY+1);
        i_loopEndX = (widthPad-i_blockSizeX+1);
        
        b_quantize = settingsHoggleBow.b_quantize;
        
        if ( b_quantize )
            myHist = zeros( length(prototypes),1 );
        end
        
        i10Percent = max( round( 0.1 * i_loopEndY ), 1);
        progressbar();         
        for y=1:i_stepSizeY:i_loopEndY
            for x=1:i_stepSizeX:i_loopEndX
                
                % get sub-image
                try
                    myBlock = imcrop(imgPad, [x,y, i_blockSizeX-1, i_blockSizeY-1]);
                catch err
                     warning( 'block cropping failed');
                end
                
  
                % compute local feature from sub-image
                myFeat = settingsHoggleBow.settingsLocalFeat.featureExtractor.mfunction ( myBlock, settingsHoggleBow.settingsLocalFeat);

                if ( b_quantize )
                    %% vector quantize the feature into our codebook
                    idxVQ = vectorQuantize ( myFeat(:), prototypes );
                    
                    myHist( idxVQ ) = myHist( idxVQ ) + 1;

                    % use the inverted prototype
                    myHoggleImg = invPrototypes { idxVQ };
                else
                    %% alternatively, invert the local feature directly ( i.e., codebook of infinite size)
                    myHoggleImg = invertHOG( max(myFeat, 0) );
                    myHoggleImg = imresize(myHoggleImg, myBlockSize);     
                    
                    % nan values occur in homogenous regions, where the
                    % inverted image is entirely black (and normalization
                    % via division is not safely implemented)
                    if ( sum(sum( isnan ( myHoggleImg(:,:) ) ) ) > 0 )
                        meanVal = round( mean(myBlock(:) ) );
                        myHoggleImg(:,:) = meanVal/255.0;
                    end                    
                end

                % draw inverted sub-image to the correct position
                imgHoggleBow( ...
                         (y+i_padSizeY):(y+i_blockSizeY-i_padSizeY-1),...
                         (x+i_padSizeX):(x+i_blockSizeX-i_padSizeX-1) ...
                      ) = ...
                      imgHoggleBow( ...
                         (y+i_padSizeY):(y+i_blockSizeY-i_padSizeY-1), ...
                         (x+i_padSizeX):(x+i_blockSizeX-i_padSizeX-1) ...
                       ) + ...
                       imcrop(myHoggleImg, [i_padSizeX+1, i_padSizeY+1, ...
                                i_blockSizeX-2*i_padSizeX-1, i_blockSizeY-2*i_padSizeY-1] ...
                             );

                % increment the counter accordingly
                imgCnt(  ...
                         (y+i_padSizeY):(y+i_blockSizeY-i_padSizeY-1),...
                         (x+i_padSizeX):(x+i_blockSizeX-i_padSizeX-1) ...
                      ) = ...
                    imgCnt(  ...
                         (y+i_padSizeY):(y+i_blockSizeY-i_padSizeY-1), ...
                         (x+i_padSizeX):(x+i_blockSizeX-i_padSizeX-1) ...
                       ) + ...
                       1;   
                   
            end
            
            % update progressbar?
            if ( mod( y,  i10Percent ) == 0 )
                disp( progressbar( y / i_loopEndY ) );
            end              
        end
        progressbar(1);          
        
        %avoid zero-entries
        imgCnt( imgCnt==0) = 1;
                
        imgHoggleBow = imgHoggleBow./imgCnt;
        
        % undo image-padding
        imgHoggleBow = imcrop( imgHoggleBow, [i_blockSizeX/2, i_blockSizeY/2, width, height] );
    else
        %% No overlapping blocks, but possible permutations (jitter)
        
        % init output value
        imgHoggleBow = zeros( height, width );            
        
        % do we really want to jitter the images?
        if ( settingsHoggleBow.b_shuffleBlocks )
            myPerm = randperm(i_numBlocksPerDim^2)-1;
        else
            myPerm = 0:i_numBlocksPerDim^2-1;
        end

        permIdxX = mod( myPerm, i_numBlocksPerDim)+1;
        permIdxY = floor( myPerm/i_numBlocksPerDim)+1;      

        b_quantize = settingsHoggleBow.b_quantize;
        
        i10Percent = max( round( 0.1 * i_numBlocksPerDim ), 1);
        progressbar();           
        for y=1:i_numBlocksPerDim
            for x=1:i_numBlocksPerDim

                i_blockIdx = (y-1)*i_numBlocksPerDim+x;
                i_blockIdxX = permIdxX ( i_blockIdx );
                i_blockIdxY = permIdxY ( i_blockIdx );

                xStart = ( i_blockIdxX-1)*i_blockSizeX+1;
                yStart = (i_blockIdxY-1)*i_blockSizeY+1;

                % get sub-image
                try
                    myBlock = imcrop(img, [xStart,yStart, i_blockSizeX-1, i_blockSizeY-1]);
                catch err
                     warning( 'block cropping failed');
                end

                myFeat = settingsHoggleBow.settingsLocalFeat.featureExtractor.mfunction ( myBlock, settingsHoggleBow.settingsLocalFeat);


                if ( b_quantize )
                    %% vector quantize the feature into our codebook
                    idxVQ = vectorQuantize ( myFeat(:), prototypes );

                    % use the inverted prototype
                    myHoggleImg = invPrototypes { idxVQ };
                else
                    %% alternatively, invert the local feature directly ( i.e., codebook of infinite size)
                    myHoggleImg = invertHOG( max(myFeat, 0) );
                    myHoggleImg = imresize(myHoggleImg, myBlockSize);                     
                end                

                % draw inverted sub-image to the correct position
                xStartDest = ( x-1)*i_blockSizeX+1;
                yStartDest = (y-1)*i_blockSizeY+1;
                xEndDest   = (x)*i_blockSizeX;
                yEndDest   = (y)*i_blockSizeY;            
                imgHoggleBow( yStartDest:yEndDest, xStartDest:xEndDest ) = myHoggleImg;
            end
            
            % update progressbar?
            if ( mod( y,  i10Percent ) == 0 )
                disp( progressbar( y / i_numBlocksPerDim ) );
            end              
        end
        progressbar(1);          
        
    end
   
    
    

     %% Show image or prepare output
    if ( nargout == 0 )
      imagesc( imgHoggleBow );
      axis image;
      axis off;
      colormap gray;
    else
      out.imgHoggleBow = imgHoggleBow;
      out.settings = settingsHoggleBow;
      
      if ( settingsHoggleBow.b_quantize )
          out.histogram = myHist;
      end
    end  
    
end