function bowHistograms = histogramPoolingOverImage(codebook, structFeatures, settings )


    i_MaxKDTreeComparisons = 15;
    
    b_StorePrototypeDistances = 0;
    codebook_transposed = codebook';
    t_kdTree = vl_kdtreebuild( codebook_transposed );

    numCBWords = size(codebook,1);
    numImages = size(structFeatures.mapImage2Data,1);
    bowHistograms = cell(numImages, 1);
    
    for iImage = 1 : numImages

        t_Descriptors = structFeatures.alldata( structFeatures.mapImage2Data{iImage} , : );
        
        if b_StorePrototypeDistances == 0
            binsa = double(vl_kdtreequery( t_kdTree, codebook_transposed, ...
                                          t_Descriptors', ...
                                          'MaxComparisons', i_MaxKDTreeComparisons)) ;
        else
            [binsa, distances] = vl_kdtreequery(t_kdTree, codebook_transposed, ...
                                                t_Descriptors', ...
                                                'MaxComparisons', i_MaxKDTreeComparisons);
            binsa = double(binsa);
        end
        h = single( hist( binsa, 1:numCBWords) );
        
        bowHistograms{iImage} = h;
        
    end
    
    bowHistograms = cat(1, bowHistograms{:});
    
    % L1 - normalize histograms
    bowHistograms = bsxfun( @times, bowHistograms, 1 ./ sum(bowHistograms,2) );
    
end