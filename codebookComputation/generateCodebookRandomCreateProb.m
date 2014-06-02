function cb = generateCodebookRandomCreateProb( structFeatures, settings )

    numWords = settings.i_numClusters;
    
    %% feature-wise distribution computation
    maxDescriptorValue = 1.0;   % maximum descriptor value
    binsDistribution = 1000;    % number of bins of the distribution
    xout = single( linspace(0,maxDescriptorValue,binsDistribution) );
    
    numFeatures = size( structFeatures.alldata,2);
    sFileDistributionDescriptorValues = 'distributionDescriptorValues.mat';
    if ~exist(sFileDistributionDescriptorValues,'file')
        % compute distribution
        distribution_descriptorValues = cell( numFeatures,1);
        progressbar();
        for iF = 1:numFeatures
            distribution_descriptorValues{iF} = single( hist( structFeatures.alldata(:,iF), xout ) )'; % compute distribution
            progressbar( iF / numFeatures );
        end
        progressbar(1);
        distribution_descriptorValues = cat(2,distribution_descriptorValues{:});
        distribution_descriptorValues = bsxfun( @times, distribution_descriptorValues, 1./sum(distribution_descriptorValues,1) );
        
        save(sFileDistributionDescriptorValues,'distribution_descriptorValues','xout');
    else
        l = load(sFileDistributionDescriptorValues);
        distribution_descriptorValues = l.distribution_descriptorValues;
        clear l;
    end
    
    %% draw feature-wise descriptor values
    cb_randInds = rand(numWords, numFeatures,'single'); % get a matrix full of uniformly distributed values (0..1) ...
    cb = cell(numFeatures,1);
    for iF = 1:numFeatures
        % ... map uniform values to the bins in the descriptor distribution 
        distCum = [0 ; cumsum(distribution_descriptorValues(:,iF) )];
        distCum(end) = distCum(end)+0.01; % in the unlikely event that any cb_randInds == 1, make sure the following histc indexing won't get index-out-of-bounds
        [~,t] = histc(cb_randInds(:,iF), distCum);
        cb{iF} = t;
    end
    cb = cat(2, cb{:});
    try
        cb = xout( cb );
    catch excp
        disp('whaaa, why!?!');
    end
    
end