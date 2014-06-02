classdef DataCachePerFile < handle
    methods
        function obj = DataCachePerFile()
            
            obj.m_bAllowOverwrite = true;
            
            obj.m_DataMap = containers.Map();
            
            obj.m_bVerbose = false;
            
            obj.m_DataIndex = 1;
        end

        function [] = setCacheFile( self, sPathCacheFile )
            self.m_sPathCacheFile = sPathCacheFile;
            [sPartDir,sPartFName,~] = fileparts( sPathCacheFile );
            self.m_CacheDataDir = [sPartDir,'/',sPartFName,'/'];
            if ~isdir( self.m_CacheDataDir )
                mkdir(  self.m_CacheDataDir );
            end
        end

        function bSuccessfull = openCacheFile(self)
            bSuccessfull = false;

            if exist(self.m_sPathCacheFile,'file')
                l = load( self.m_sPathCacheFile); %, 'data', 'keymap');
                self.m_DataMap = l.datamap;
                %get index to continue with
                self.m_DataIndex = length( l.datamap) + 1;
                % perform sanity check
                t = unique( cellfun(@(c)c, l.datamap.values));
                assert( length( t) == length( l.datamap)); % meaning: for every filename key there is only one matchin index  allowed
                clear l
                
                bSuccessfull = true;
            else
                warning(['CacheData: cache file does not exist: ',self.m_sPathCacheFile]);
            end
        end
        
        function data = getData(self, sImageFilename )
            data = [];
            try
                index = self.m_DataMap( sImageFilename );
                sNewDataFilename = sprintf( '%s%d.cache.mat', self.m_CacheDataDir, index);
                if exist(sNewDataFilename,'file')
                    l = load( sNewDataFilename );
                    data = l.data;
                else
                    if ( self.m_bVerbose )
                        fprintf(' image feature mapping available, but feature cache file not available for %s\n',sImageFilename);
                    end
                end
            catch excp
                if ( self.m_bVerbose )
                    fprintf(' image features not available for %s\n',sImageFilename);
                end
            end
                
        end
        
        function bSuccess = setData(self, sImageFilename, data )
            bSuccess = false;
            %% map filename to a increasing number
            self.m_DataMap( sImageFilename ) = self.m_DataIndex;
            
            %% create data to the number in the cache directory
            sNewDataFilename = sprintf( '%s%d.cache.mat', self.m_CacheDataDir, self.m_DataIndex);
            if self.m_bAllowOverwrite || ~exist(sNewDataFilename,'file')
                save(sNewDataFilename, 'data', 'sImageFilename','-v7.3');
            else
                warning(['DataCachePerFile:CloseCache: cache already exists and overwrite is false: ',sNewDataFilename]);
            end
            
            %%
            self.m_DataIndex = self.m_DataIndex +1;
            bSuccess = true;
            self.m_bCacheChanged = true;
        end
        
        function flushCache(self)
            if self.m_bCacheChanged 
                if self.m_bAllowOverwrite || ~exist(self.m_sPathCacheFile,'file')
                    datamap = self.m_DataMap;
                    cacheDataDir = self.m_CacheDataDir;
                    save(self.m_sPathCacheFile, 'datamap','cacheDataDir','-v7.3');
                    clear datamap cacheDataDir
                    self.m_bCacheChanged  = false;
                else
                    warning(['DataCachePerFile:CloseCache: cache already exists and overwrite is false: ',self.m_sPathCacheFile]);
                end
            end
        end
        
        function closeCache(self)
            %saving buffer
            self.flushCache();
            
            self.m_DataMap = [];
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        m_DataMap
        m_CacheDataDir
        m_DataIndex
        
        m_bAllowOverwrite
        
        m_sPathCacheFile;
        m_bCacheChanged
        
        m_bVerbose;
    end
end




