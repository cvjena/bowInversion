function hogFeature = extractHOG ( img, settings )
%%TODO docu

    %% (1) check input
    if ( ( nargin >= 2 ) && ...
         ( ~isempty (settings) ) && ...
         ( isstruct ( settings ) ) && ...
         ( isfield(settings, 'sbin')  )...
       )
        sbin = settings.sbin;
    %just for backward compatibility we check both options
    elseif ( ( nargin >= 2 ) && ...
             ( ~isempty (settings) ) && ...
             ( isstruct ( settings ) ) && ...
             ( isfield(settings, 'i_binSize')  )...
           )
        sbin = settings.i_binSize;
    else
        sbin = 8;
    end
    
    %% (2) compute features
    if ( ndims(img) == 3 )
        hogFeature = featuresHOGColor( double(img), sbin );
    else
        hogFeature = featuresHOGGrayScale( double(img), sbin );
    end   
    
end
