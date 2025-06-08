/**********************************************************************************************
@author    		Sapient : Ramdev Chahar
@date      		9 August 2022
@description: 	Test class for ASDAC_ObjectSystemInformationController
**********************************************************************************************/
@isTest
public class ASDAC_ObjectSystemInformation_Test {
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		9 August 2022
	@description	Test method for ASDAC_ObjectSystemInformationController.getTimeZoneOfUser method
	**********************************************************************************************/
    @isTest
    public static void testGetTimeZoneOfUser(){
        String username = (System.URL.getSalesforceBaseUrl()+'').Split('//')[1]+'test@asdatest.co.uk';
        Id profileId = UserInfo.getProfileId();
        User u = ASDAC_TestDataUtility.getUser(username,profileId);
        insert u;
        test.startTest();
        ASDAC_ObjectSystemInformationController.getTimeZoneOfUser(u.Id);
        test.stopTest();
    }

}