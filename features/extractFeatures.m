function structFeatures = extractFeatures( settings, dataset, labelsTrain )
%FIXME docu!


    structFeatures.alldata = cell(length( labelsTrain ),1); %first, insert data in cells, and then create one big sample-feature-matrix (for storage reasons)
    % mapping that point for each image to the extracted features by
    % providing indices to structFeatures.alldata:
    % example: features_image2 = structFeatures.alldata( structFeatures.mapImage2Data{2}, :)
    structFeatures.mapImage2Data = cell(length( labelsTrain ),1); 

    iOffset = 0;
    
    if ( settings.b_progressbar )
        i10Percent = max( round( 0.1 * length( labelsTrain ) ), 1);
        progressbar();
    end
    
    %loop over all images
    for iImg = 1 : length( labelsTrain )
        
        i_currImage = labelsTrain(iImg);
        
        s_imgfn = dataset.images{ i_currImage };
        
        t_ImageFeatures = settings.dataCache.getData( s_imgfn );
        
        if isempty(t_ImageFeatures) % cache didnt have precomputed features

            % read given image
            img = imread ( s_imgfn);

            % is it 256px-squared image? if not, make it 256px-squared!
            if size(img,1) ~= 256 || size(img,2) ~= 256
                sizeMax = 256; %max( size(img) );
                img = imresize( img, [sizeMax,sizeMax], 'bilinear'); %linear interpolation
            end

             % convert gray image into color image
            if length(size(img)) == 2
                img = repmat(img,[1,1,3]);
            end

            [height,width,~] = size(img);

            if ( settings.b_overlappingBlocks )
            % overlapping blocks - but no permutations...
                i_blockSizeX = settings.i_blockSizeX;
                i_blockSizeY = settings.i_blockSizeY;

                img     = padarray(img,[i_blockSizeX/2,i_blockSizeY/2]);
                width   = width  + i_blockSizeX;
                height  = height + i_blockSizeY;
                
                i_stepSizeX = settings.i_stepSizeX;
                i_stepSizeY = settings.i_stepSizeY;
                
                i_loopEndY = (height-i_blockSizeY+1);
                i_loopEndX = (width-i_blockSizeX+1);
                
                vecBlockCentersX = 1:i_stepSizeX:i_loopEndX;
                vecBlockCentersY = 1:i_stepSizeY:i_loopEndY;
            else
                % distinct  blocks (no overlap)
                i_numBlocksPerDim = settings.i_numBlocksPerDim;        

                i_blockSizeX = floor( height / i_numBlocksPerDim );
                i_blockSizeY = floor( width / i_numBlocksPerDim );
                
                vecBlockCentersX = ( 1:i_numBlocksPerDim)*i_blockSizeX+1;
                vecBlockCentersY = ( 1:i_numBlocksPerDim)*i_blockSizeY+1;
            end

            % extract dense features
            t_ImageFeatures = cell( length(vecBlockCentersY)*length(vecBlockCentersX), 1);
            iCurrBlockSample = 1;
            for y = vecBlockCentersY
                for x = vecBlockCentersX

                    % get sub-image
                    try
                        %old myBlock = imcrop(img, [xStart,yStart, i_blockSizeX-1, i_blockSizeY-1]);
                        myBlock = imcrop(img, [x,y, i_blockSizeX-1, i_blockSizeY-1]);                        
                    catch err
                         warning( 'block cropping failed');
                    end

                    % and compute hog features accordingly
                    % division by 6 leads to 4 x 4 hog arrays... for further
                    % details and explanations check the features-code!            
%                     myStruct.img = myBlock;
%                     myStruct.i_cellSizeX = i_blockSizeX/6;
%                     myStruct.i_cellSizeY = i_blockSizeY/6;
                    myFeat = settings.featureExtractor.mfunction ( myBlock, settings);                


                    % collect and concatenate all features over all images
                    t_ImageFeatures{iCurrBlockSample} = myFeat(:)';
                    iCurrBlockSample = iCurrBlockSample +1;
                end
            end
            t_ImageFeatures = cat(1,t_ImageFeatures{:});
            
            % insert features in cache
            settings.dataCache.setData( s_imgfn, t_ImageFeatures);
        end
        
        structFeatures.mapImage2Data{iImg} = iOffset + [1:size(t_ImageFeatures,1)];
        
        structFeatures.alldata{iImg} = t_ImageFeatures;
        iOffset = iOffset + size(t_ImageFeatures,1);
        
        if ( settings.b_progressbar )
            if mod( iImg,  i10Percent ) == 0
                disp( progressbar( iImg / length( labelsTrain ) ) );
            end
        end
    end
    
    if ( settings.b_progressbar )
        progressbar(1);
    end

    % create matrix from cell array
    structFeatures.alldata = cat(1,structFeatures.alldata{:});
    
    % save calculated and added features
    settings.dataCache.flushCache();

end