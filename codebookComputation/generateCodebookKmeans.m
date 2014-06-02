function cb = generateCodebookKmeans( structFeatures, settings )

    numWords = settings.i_numClusters;
    numSamples = size( structFeatures.alldata,1);
    
    if isfield(settings,'codebook_kmeans_sample_subselection') ...
        && settings.codebook_kmeans_sample_subselection ~= -1 ...
        && settings.codebook_kmeans_sample_subselection < numSamples
        %perfrom sample subselection for reduced clustering effort
        
        
        indsSubselection = vl_colsubset( 1:numSamples,  settings.codebook_kmeans_sample_subselection ,'random');
        t_data =  structFeatures.alldata( indsSubselection, :);
        t_data = t_data';
        
        [cb, ~] = vl_kmeans( t_data, numWords, 'algorithm', 'elkan');
        cb = cb';        
    else
        [cb, ~] = vl_kmeans( structFeatures.alldata', numWords, 'algorithm', 'elkan');
        cb = cb';
    end


    %vocabulary = yael_kmeans( single(matDescriptorsInCol), single( config.numWords ), 'verbose', false );

    
end