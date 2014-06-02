classdef DataCache < handle
    methods
        function obj = DataCache()
            
            obj.m_bAllowOverwrite = true;
            
            obj.m_DataMap = containers.Map();
            
            obj.m_bVerbose = false;
        end

        function [] = setCacheFile( self, sPathCacheFile )
            self.m_sPathCacheFile = sPathCacheFile;
        end

        function bSuccessfull = openCacheFile(self)
            bSuccessfull = false;

            if exist(self.m_sPathCacheFile,'file')
                l = load( self.m_sPathCacheFile ); %, 'data', 'keymap');
                self.m_DataMap = l.datamap;
                clear l
                
                bSuccessfull = true;
            else
                warning(['CacheData: cache file does not exist: ',self.m_sPathCacheFile]);
            end
        end
        
        function data = getData(self, sImageFilename )
            data = [];
            try
                data = self.m_DataMap( sImageFilename );
            catch excp
                if ( self.m_bVerbose )
                    fprintf(' image features not available for %s\n',sImageFilename);
                end
            end
                
        end
        
        function bSuccess = setData(self, sImageFilename, data )
            bSuccess = false;
            self.m_DataMap( sImageFilename ) = data;
            bSuccess = true;
            self.m_bCacheChanged = true;
        end
        
        function flushCache(self)
            if self.m_bCacheChanged 
                if self.m_bAllowOverwrite || ~exist(self.m_sPathCacheFile,'file')
                    datamap = self.m_DataMap;
                    save(self.m_sPathCacheFile, 'datamap','-v7.3');
                    clear datamap;
                    self.m_bCacheChanged  = false;
                else
                    warning(['DataCache:CloseCache: cache already exists and overwrite is false: ',self.m_sPathCacheFile]);
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
        
        m_bAllowOverwrite
        
        m_sPathCacheFile;
        m_bCacheChanged
        
        m_bVerbose;
    end
end




