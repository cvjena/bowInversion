% function hogFeature = featuresHOGGrayScale( img, sbin );
% 
% BRIEF:
%    Compute an array of extended HOG features for a given gray scale image. 
%    Original implementation did not supported simply gray scale images.
%    Additionally, differs from the original implementation (featuresHOGorig.cc)
%    by not leaving a boundary of sbin pixels at the border of the image "unused".
% 
%    Advantage:    k*sbin pixel result in k cells (orig: k-2)
%    Disadvantage: block normalization ill posed on boundary
%
% INPUT:
%    img   -- (x,y) double array, input image
%    sbin  -- double scalar, number of pixels each cell covers in x and y
%             direction
%
% OUTPUT:
%    hogFeature   -- (x/sbin, y/sbin, 32) double array,
%                    extracted hog array, last dim equals 0
% 
% NOTE:
%    Don't miss to mex (compile) the .cc-file!
%   
% author: Alexander Freytag
% last update: 11-03-2014 ( dd-mm-yyyy )
% 