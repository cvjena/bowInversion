function structResults = bowComparison_15Scenes( settings )
% function structResults = bowComparison_15Scenes( settings )
% 
% author: Alexander Freytag, Johannes Ruehle
% date  : 28-05-2014 ( dd-mm-yyyy )
% 
% BRIEF:
%    Evaluate a standard bag-of-visual-words pipelin on the 15Scenes
%    dataset, using several random splits. Pipeline consists of local
%    feature extraction, clustering for codebook creation, vector quantization 
%    with spatial, classifier training, and evaluation on unseen test
%    images.
%    Comparison can be done wrt. to several codebook generation techniques
%    specified.
% 
% INPUT:
%    settings      -- struct, all non-specified variables are set to default
%                     values ( see setupVariables/*.m)
% 
% OUTPUT:
%    structResults -- struct, with fields 'perf_values_arr',
%                     'perf_values_ovacc', 'perf_mean_entropy_test',
%                     'perf_var_entropy_test', 'perf_mean_entropy_train',
%                     'perf_var_entropy_train', 'summed_histograms_test',
%                     'summed_histograms_train', 'splits', 'usedSettings'
% 

   

    %% (0) check input
    if ( nargin < 1)
        settings = [];
    end

    %% ( 1 ) set up variables, initialize outputs

    mySettings = setupVariables_BoWEval( settings );
    
    % open the cache file with all feature data
    debug_disp( 'load cached features', mySettings);
    mySettings.settingsLocalFeat.dataCache.openCacheFile();

    % load imagenet data
    debug_disp( 'load 15Scenes data...', mySettings);
    dataset15Scenes = init15Scenes( mySettings.settingsDataset );
    
    % init output variables
    structResults.perf_values_arr         =  zeros( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits,'single');    
    structResults.perf_values_ovacc       =  zeros( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits,'single');                                          
    structResults.perf_mean_entropy_train =  zeros( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits,'single');                                          
    structResults.perf_mean_entropy_test  =  zeros( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits,'single');
    structResults.perf_var_entropy_train  =  zeros( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits,'single');                                          
    structResults.perf_var_entropy_test   =  zeros( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits,'single');
    structResults.summed_histograms_train =  cell( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits);
    structResults.summed_histograms_test  =  cell( length(mySettings.settingsClustering.codebookStrategies), ...
                                               mySettings.settingsEval.i_numRandomSplits);
    structResults.splits                  = cell(mySettings.settingsEval.i_numRandomSplits,1 );  
    
    %% ( 2 ) run evaluation on several splits
  
    for i_split=1:mySettings.settingsEval.i_numRandomSplits
            debug_disp(sprintf('Split %d of %d ==============', i_split, mySettings.settingsEval.i_numRandomSplits), mySettings);
            
            % split into train and test (and perhaps val)
            structSplit = mySettings.settingsDataset.splitTrainTest.mfunction( dataset15Scenes, mySettings.settingsDataset);
%            structSplit = splitTrainTest_Percentage( dataset15Scenes, mySettings);
            
            classesUsed = unique(structSplit.labelsTrain );
            noClasses = size(classesUsed, 2 );
            
            % extract local features for training images
            debug_disp('extract training sample features', mySettings);
            structFeaturesTrain = extractFeatures( mySettings.settingsLocalFeat, dataset15Scenes, structSplit.indicesTrainImages );

            debug_disp('extract test sample features', mySettings);
            structFeaturesTest  = extractFeatures( mySettings.settingsLocalFeat, dataset15Scenes, structSplit.indicesTestImages );

            %NOTE the following stuff could be encapsulated into a separte
            %file, generic for various datasets (getting images, splits, and
            %method settings)
            for i_cbTechniqueIndex=1:length(mySettings.settingsClustering.codebookStrategies)
                debug_disp( sprintf('cb %s : cb clustering', mySettings.settingsClustering.codebookStrategies{ i_cbTechniqueIndex }.name), mySettings.settingsClustering);
                % perform clustering for current method
                codebookMethod = mySettings.settingsClustering.codebookStrategies{ i_cbTechniqueIndex }.mfunction;
                codebook = codebookMethod(structFeaturesTrain, mySettings.settingsClustering );
                
                % quantize local features into histograms
                debug_disp( 'train features histogram pooling', mySettings);
                bowFeaturesTrain = mySettings.settingsClustering.histogramPooling.mfunction(codebook,structFeaturesTrain,mySettings.settingsClustering);
                
                % expansion of features to approximate better kernels than the linear
                % one
                if strcmp( mySettings.settingsClassification.s_svm_Kernel , 'linear')
                    %nothing to be done here, features stay the same
                elseif strcmp( mySettings.settingsClassification.s_svm_Kernel , 'intersection')
                    bowFeaturesTrain = vl_homkermap(bowFeaturesTrain', mySettings.settingsClassification.i_homkermap_n, 'kinters', 'gamma', mySettings.settingsClassification.d_homkermap_gamma)' ;
                elseif strcmp( mySettings.settingsClassification.s_svm_Kernel , 'chi-squared')      
                    bowFeaturesTrain = vl_homkermap(bowFeaturesTrain', mySettings.settingsClassification.i_homkermap_n, 'kchi2', 'gamma', mySettings.settingsClassification.d_homkermap_gamma) ;
                    bowFeaturesTrain = bowFeaturesTrain';
                else
                    error('invalid kernel, kernel %s is not impelemented',config.s_svm_Kernel);
                end
                
                %% train classifier
                
                % assumes multi-class settings, not binary
                debug_disp( 'SVM: parameter optimization', mySettings);
                paramC = 10.^[-3:0.3:3];
                t_valAccuracy = zeros( length(paramC),1 );
                for iC = 1:length(paramC)
                    paramSettings = sprintf('%s -c %0.4f -v 10', mySettings.settingsClassification.s_SvmSettingsTrain, paramC(iC) );
                    t_valAccuracy(iC) = train ( structSplit.labelsTrain', sparse( double(bowFeaturesTrain) ), paramSettings );
                end
                [~,idxBestModel] = max( t_valAccuracy );
                debug_disp( sprintf('SVM: train: c=%0.3f', paramC(idxBestModel) ) , mySettings);
                paramSettings = sprintf('%s -c %0.4f', mySettings.settingsClassification.s_SvmSettingsTrain, paramC(idxBestModel) );
                svmModel = train ( structSplit.labelsTrain', sparse( double(bowFeaturesTrain) ), paramSettings );

                %cross check: number of classes should be equal to the estimated
                %number
                if ( svmModel.nr_class ~= noClasses )
                    errorMsg = sprintf( ' problem in training: number of classes after train method is %i - expected %i', svmModel.nr_class, noClasses);
                    disp(errorMsg)
                end                 
                
                % quantize local features into histograms
                debug_disp( 'test features histogram pooling', mySettings);
                bowFeaturesTest = mySettings.settingsClustering.histogramPooling.mfunction(codebook,structFeaturesTest,mySettings.settingsClustering);
                
                % expansion of features to approximate better kernels than the linear one
                if strcmp( mySettings.settingsClassification.s_svm_Kernel , 'linear')
                    %nothing to be done here, features stay the same
                elseif strcmp( mySettings.settingsClassification.s_svm_Kernel , 'intersection')
                    debug_disp( 'expansion of features: Homkermap, intersection', mySettings);
                    bowFeaturesTest = vl_homkermap(bowFeaturesTest', mySettings.settingsClassification.i_homkermap_n, 'kinters', 'gamma', mySettings.d_homkermap_gamma)';
                elseif strcmp( mySettings.settingsClassification.s_svm_Kernel , 'chi-squared')
                    debug_disp( 'expansion of features: Homkermap, chi-squared', mySettings);
                    bowFeaturesTest = vl_homkermap(bowFeaturesTest', mySettings.settingsClassification.i_homkermap_n, 'kchi2', 'gamma', mySettings.d_homkermap_gamma)';
                else
                    error('invalid kernel, kernel %s is not impelemented',config.s_svm_Kernel);
                end                

                %%  evaluate classifier                
                debug_disp( 'predict classes using SVM', mySettings);
                [predicted_label, ~, ~] = predict(double(structSplit.labelsTest'), sparse( double(bowFeaturesTest) ), svmModel, mySettings.settingsClassification.s_SvmSettingsPredict );

                % evaluate accuracy
                overallAccuracy =  sum(predicted_label==structSplit.labelsTest')/ length(predicted_label);

                classwiseARR = zeros(length(classesUsed) ,1);

                %check which samples are from which class
                for i = 1:length( classesUsed ) 
                    classIdx = find( structSplit.labelsTest == classesUsed(i) );

                     %average over samples of classes separately
                    classwiseARR(i) = sum(predicted_label(classIdx)==structSplit.labelsTest(classIdx)')/ length(predicted_label(classIdx));
                end

                %average accuracy results over all classes
                averageAccuracy =  mean( classwiseARR( ~isnan ( classwiseARR ) ) );
                
                debug_disp( sprintf('mean acc:%1.3f',averageAccuracy), mySettings);
                
                structResults.perf_values_arr  ( i_cbTechniqueIndex, i_split) = averageAccuracy;                
                structResults.perf_values_ovacc( i_cbTechniqueIndex, i_split) = overallAccuracy;
                
                t_entropy = bowFeaturesTest .* log2(bowFeaturesTest);
                t_entropy( isnan(t_entropy)) = 0;
                t_entropy = -sum(t_entropy,2);
                structResults.perf_mean_entropy_test( i_cbTechniqueIndex, i_split)  = mean( t_entropy );
                structResults.perf_var_entropy_test( i_cbTechniqueIndex, i_split)   = var( t_entropy );
                
                t_entropy = bowFeaturesTrain .* log2(bowFeaturesTrain);
                t_entropy( isnan(t_entropy)) = 0;
                t_entropy = -sum(t_entropy,2);
                structResults.perf_mean_entropy_train( i_cbTechniqueIndex, i_split) = mean( t_entropy );
                structResults.perf_var_entropy_train( i_cbTechniqueIndex, i_split)  = var( t_entropy );
                
                structResults.summed_histograms_test{i_cbTechniqueIndex, i_split}   = sum( bowFeaturesTest,1);
                structResults.summed_histograms_train{i_cbTechniqueIndex, i_split}  = sum( bowFeaturesTrain,1);
            end
            
            structResults.splits{i_split} = structSplit;
        
    end
    
    %% close the cache file with all feature data
    mySettings.settingsLocalFeat.dataCache.closeCache();
    
    structResults.usedSettings = mySettings;
    
end