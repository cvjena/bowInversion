function invPrototypes = invertPrototypes ( codebook, i_myBlockSize )
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )

    if ( nargin < 2 )
        i_myBlockSize = [128,128];
    end

    invPrototypes = [];
    
    i10Percent = max( round( 0.1 * size( codebook,1 ) ), 1);
    progressbar();    

    for idxPrototype = size( codebook,1 ):-1:1
        
        % get hog feature of current prototpye
        myPrototype = codebook( idxPrototype, :  );

        %FIXME adaptive!
        i_numDimHOG = 32;        
        
        i_numCellsX = round( sqrt( size(myPrototype,2) / i_numDimHOG));
        i_numCellsY = round( sqrt( size(myPrototype,2) / i_numDimHOG));

        myPrototype = reshape( myPrototype, [i_numCellsY,i_numCellsX,i_numDimHOG] );
        
        % do the inversion
        myHoggleImg = invertHOG( max( myPrototype, 0) );
        
        % scale to proper size
        %TODO: perhaps we should think about doing this lateron?!        
        invPrototypes{ idxPrototype } = imresize(myHoggleImg, i_myBlockSize);
        
        if ( mod( idxPrototype,  i10Percent ) == 0 )
            disp( progressbar( (size( codebook,1 )-idxPrototype) / size( codebook,1 ) ) );
        end        
    end
    
    progressbar(1);    
end