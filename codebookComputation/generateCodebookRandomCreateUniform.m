function cb = generateCodebookRandomCreateUniform( structFeatures, settings )

    numWords = settings.i_numClusters;
    
    cb = rand(numWords, 512,'single'); % drawn from uniform distribution between (0,1]
end