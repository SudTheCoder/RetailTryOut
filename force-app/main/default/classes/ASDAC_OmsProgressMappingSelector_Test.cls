@isTest
private class ASDAC_OmsProgressMappingSelector_Test {
	
    private final static String USER_NAME = 'testUser_0@testing_0.com.ocsColleagueBPO';
    
    /**************************************************************************
    Purpose    : Test Setup data                                           
    Parameters : NA
    Returns    : NA                                        
    **************************************************************************/ 
    @TestSetup
    static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);  
    }
    
    @isTest
    static void testFindBy() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            // Test finding the record
            ASDAC_OmsProgressMapping__mdt result = ASDAC_OmsProgressMappingSelector.findBy('GHS_CNC', 'Collected');
            System.assertEquals('Collected', result.StatusLabel__c);
            System.assertEquals(2, result.ProgressDot__c);
            
            // Test not finding the record
            result = ASDAC_OmsProgressMappingSelector.findBy('Nonexistent Fulfillment Type', 'Nonexistent Order Status');
            System.assertEquals(null, result);
        }
    }
    
    /**************************************************************************
    Purpose    : Get User Record                                           
    Parameters : username
    Returns    : User record                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
}