function structSplit = splitTrainTest_Percentage( dataset, mySettings)
    numImages = length( dataset.images );
    nChooseLabeledTrainSamples = round( mySettings.f_numTrainImagesPercentage*numImages );
    indicesTrainImages         = vl_colsubset( 1:numImages, nChooseLabeledTrainSamples,'random');
    
    mask                     = true(1,numImages);
    mask(indicesTrainImages) = false;
    
    indicesTestImages = find(mask);
    assert( isempty( intersect( indicesTestImages, indicesTrainImages) ) ); %non-overlapping train-test indices!

    structSplit.indicesTrainImages = indicesTrainImages;
    structSplit.indicesTestImages  = indicesTestImages;
    
    if isfield( dataset, 'labels')
        structSplit.labelsTrain = dataset.labels( indicesTrainImages );
        structSplit.labelsTest  = dataset.labels( indicesTestImages );
    end
end