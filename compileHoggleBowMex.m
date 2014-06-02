% Run this script to compile the mex files used in this system.

fprintf('compiling featuresHOGColor.cc\n');
mex -O features/hog/featuresHOGColor.cc -o features/hog/featuresHOGColor

fprintf('compiling featuresHOGGrayScale.cc\n');
mex -O features/hog/featuresHOGGrayScale.cc -o features/hog/featuresHOGGrayScale