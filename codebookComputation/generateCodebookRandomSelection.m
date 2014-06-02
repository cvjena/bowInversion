function cb = generateCodebookRandomSelection( structFeatures, settings )
    

    numWords = settings.i_numClusters;
    numSamples = size(structFeatures.alldata,1);
    
    %Info toward vl_colsubset: returns a random subset Y of N columns of
    %   X. The selection is order-preserving and without replacement
    indicesRand = vl_colsubset( 1:numSamples, numWords,'random');
    assert( length( unique(indicesRand) ) == numWords );
    
    cb = structFeatures.alldata( indicesRand, :);
    
end