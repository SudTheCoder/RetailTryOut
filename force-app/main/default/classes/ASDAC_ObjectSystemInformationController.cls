/**********************************************************************************************
@author    		Sapient : Ramdev Chahar
@date      		9 August 2022
@description: 	Controller class for asdacObjectSystemInformationCmp Component
**********************************************************************************************/
public with sharing class ASDAC_ObjectSystemInformationController {
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		9 August 2022
	@param			String userId
	@return			String TimeZone of the User
	@description	This method return the timezone of the user of which id is passed in param
	**********************************************************************************************/
    @AuraEnabled
    public static string getTimeZoneOfUser(String userId){
        String timeZone;
        List<User> userList = [SELECT TimeZoneSidKey
                               FROM User
                               WHERE Id =: userId
                               WITH SECURITY_ENFORCED];
        if(userList != null && userList.size()>0){
            timezone = userList[0].TimeZoneSidKey;
        }
        return timeZone;
    }
}