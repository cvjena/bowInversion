function structSplit = splitTrainTest_FixedNumberPerClass( dataset, mySettings)
    
    %mySettings.i_TrainSplitImagesPerClass;

    numImages = length( dataset.images );    
    uniqueClasses = unique(dataset.labels);
    numClasses = length( uniqueClasses );
    %% first: check whether every class has enough train samples at all
    
    nSamplesPerClass = hist( dataset.labels, uniqueClasses);
    nSamplesPerClass = min( nSamplesPerClass, repmat(mySettings.splitTrainTest.i_TrainSplitImagesPerClass, 1,numClasses) );
%     if any( nSamplesPerClass < mySettings.i_TrainSplitImagesPerClass )
%        error('not enough train samples per class');
%     end
    
    
    %% train indices
    indicesTrainImages = cell(numClasses,1);
    for iC = 1:numClasses
        indsClassImages = find( dataset.labels == uniqueClasses(iC) );
        t_chosen = vl_colsubset( indsClassImages, nSamplesPerClass(iC),'random');    
        indicesTrainImages{iC} = t_chosen;
    end
    indicesTrainImages = cat(2, indicesTrainImages{:});
    
    %% test indices
    mask = true(1,numImages);
    mask(indicesTrainImages) = false;
    indicesTestImages = find(mask);
    assert( isempty( intersect( indicesTestImages, indicesTrainImages) ) ); %non-overlapping train-test indices!

    structSplit.indicesTrainImages = indicesTrainImages;
    structSplit.indicesTestImages  = indicesTestImages;
    structSplit.labelsTrain = dataset.labels( indicesTrainImages );
    structSplit.labelsTest  = dataset.labels( indicesTestImages );
end