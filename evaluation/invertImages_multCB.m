dataset = init15Scenes;

if ( ~exist( 'b_loadCodebooks', 'var' ) )
    b_loadCodebooks = true;
end

if ( b_loadCodebooks )
    load( '/home/freytag/experiments/hoggleBow/codebooks/15scenes/32/codebook.mat' );
    load( '/home/freytag/experiments/hoggleBow/codebooks/15scenes/128/codebook.mat' );
    load( '/home/freytag/experiments/hoggleBow/codebooks/15scenes/512/codebook.mat' );
    load( '/home/freytag/experiments/hoggleBow/codebooks/15scenes/2048/codebook.mat' );
    codebooks = { cb32, cb128, cb512, cb2048 };
else
    codebooks = [];
end


settings = addDefaultVariableSetting ( settings, 'b_saveImages', true, settings);

settings = addDefaultVariableSetting ( settings, 's_destinationPrefix', '/home/freytag/experiments/2014-04-02-invert15Scenes/', settings );

% only vector quantized visualizations here, noVQ takes too much time
settings = addDefaultVariableSetting ( settings, 'b_alsoWithoutVQ',  false , settings );

if ( ~exist( 'i_start', 'var' ) )
    i_start = 1;
end

if ( ~exist( 'i_end', 'var' ) )
    i_end = size(dataset.images,2);
end

if ( ~exist( 'i_stepSizeProgressBar', 'var' ) )
    i_stepSizeProgressBar = 10;
end



for i=i_start:i_end 
    if( rem(i-1,i_stepSizeProgressBar)==0 )
        fprintf('%d / %d\n', i, i_end );
    end    
    
    eval_visualizeHoggleBow_multCB(codebooks, dataset.images{i}, settings);
end
