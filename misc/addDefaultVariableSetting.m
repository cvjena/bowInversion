function newSetting = addDefaultVariableSetting( setting, strSettingName, value, newSetting )
% function newSetting = addDefaultVariableSetting( setting, strSettingName, value, newSetting )
% 
% author: Alexander Freytag
% data:   04-02-2014 (dd-mm-yyyy)

  if ( ( ~isfield(setting,strSettingName))  || isempty(setting.(strSettingName) ) )
        newSetting.(strSettingName) = value;
  else
        newSetting.(strSettingName) = setting.(strSettingName);
  end  
  
end