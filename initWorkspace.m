function initWorkspace
% function initWorkspace
% 
% author: Alexander Freytag
% date  : 27-05-2014 ( dd-mm-yyyy )
% 
% BRIEF:
%    Set up all necessary patchs and variables. Mex-files are compiled if
%    not done already.


    IHOGDIR = '';
    LIBLINEARDIR = '';
    VLFEATDIR    = '';
    TSNEDIR = '';    
    
    if strcmp( getenv('USER'), 'freytag')
        IHOGDIR      = '~/code/3rdParty/inverseHoG/';        
        LIBLINEARDIR = '~/code/3rdParty/liblinear-1.93/matlab/';
        VLFEATDIR    = '~/code/3rdParty/vlfeat/';
        
    elseif strcmp( getenv('USER'), 'rodner')        
        LIBLINEARDIR = '~/thirdParty/liblinear-1.92/matlab/';
        VLFEATDIR    = '~/thirdParty/vlfeat/';
        IHOGDIR      = '~freytag/code/3rdParty/inverseHoG/'; 
        
    elseif strcmp( getenv('USER'), 'ruehle')        
        IHOGDIR      = '~/libs/inverseHoG/';          
        LIBLINEARDIR = '~/libs/liblinear-1.92/matlab/';
        VLFEATDIR    = '~/libs/vlfeat/';
        TSNEDIR      = '~/code/matlab/libs/Simple_tSNE/';
        
    elseif strcmp( getenv('USER'), 'bodesheim') 
        IHOGDIR      = '~/src/matlab/sharedCode/ihog/';        
        VLFEATDIR    = '~/src/matlab/sharedCode/vlfeat/vlfeat/';
       
    else
        fprintf('Unknown user %s and unknown default settings', getenv('USER') );
        return;
    end

    %% add paths to our own code
    % several useful scripts
    addpath( [pwd(),'/misc/']);
    
    % all about features used
    addpath( genpath( [pwd(),'/features/']) );    
    
    % data and data generation
    addpath( [pwd(),'/data/']);    
    
    % stuff for variable settings
    addpath( [pwd(),'/setupVariables/']);   
    
    % all the evaluation scripts
    addpath( [pwd(),'/evaluation/']);       
       
    % clustering techniques to compute codebooks from sets of local
    % features
    addpath( [pwd(),'/codebookComputation/']);     
    
    % all demo files
    addpath( [pwd(),'/demos/']);     
    

    
    %% add path to 3rd party, untouched
    
    if ( isempty(IHOGDIR) )
        fprintf('WARNING = no LIBLINEARDIR dir found on your machine. Code is available at http://www.csie.ntu.edu.tw/~cjlin/liblinear/ \n');
    else
        addpath(genpath(LIBLINEARDIR));
    end
    
    if ( isempty(VLFEATDIR) )
        fprintf('WARNING = no VLFEATDIR dir found on your machine. Code is available at http://www.vlfeat.org/ \n');
    else
        addpath(genpath(VLFEATDIR));
        % setup vl feature
        current_dir = pwd;
        cd( VLFEATDIR )
        vl_setup();
        disp(['using vlfeat ',vl_version()]);
        cd(current_dir);        
    end     

    
    if ( isempty(IHOGDIR) )
        fprintf('ERROR: no IHOG dir found on your machine. Code is available at https://github.com/CSAILVision/ihog \n');
    else
        addpath(genpath(IHOGDIR));
    end    
    
    if ( isempty(TSNEDIR) )
        fprintf('WARNING: no Simple t-SNE dir found on your machine. Code is available at http://homepage.tudelft.nl/19j49/t-SNE.html \n');
    else
        addpath(genpath(TSNEDIR));
    end  
    
    %% clean-up
    clear( 'IHOGDIR' );    
    clear( 'LIBLINEARDIR' );
    clear( 'VLFEATDIR' );
    clear( 'TSNEDIR' );
    
    clear;
    
    %% finally, compile all necessary mex-files delivered with this small package
    if ( ~exist ( './features/hog/featuresHOGColor.mexa64', 'file') && ~exist ( './features/hog/featuresHOGColor.mexaw32', 'file') )
        compileHoggleBowMex
    end
    
end



