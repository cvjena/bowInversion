function [ idxVQ, distVQ ] = vectorQuantize ( myFeat, prototypes )
    %TODO possibly add options for distance metric, hashing,  and stuff like that
    
    %TODO check that dimensions are consistent
    
    distances = bsxfun(@minus, prototypes, myFeat' ) ;
    distanceNorms = arrayfun(@(idx) norm(distances(idx,:)), 1:size(distances,1) );

    [minDist, idxVQ] = min ( distanceNorms );
    
    if ( nargout > 1 )
        distVQ = minDist;
    end
end