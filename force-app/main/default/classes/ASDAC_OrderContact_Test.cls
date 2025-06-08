@isTest
public class ASDAC_OrderContact_Test {
	
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
    static void testASDAC_OrderContact(){       
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_OrderContact orderContact = new ASDAC_OrderContact();
            orderContact.firstName = 'abc';
            orderContact.middleName = 'xyz';
            orderContact.lastName = 'test';
            orderContact.phone = '123456789';
            orderContact.email = 'test@asdatest.co.uk';
            
            System.assertEquals('abc',orderContact.firstName);
            System.assertEquals('xyz', orderContact.middleName);
            System.assertEquals('test', orderContact.lastName);
            System.assertEquals('abc xyz test', orderContact.name);
            System.assertEquals('123456789', orderContact.phone);
            System.assertEquals('test@asdatest.co.uk', orderContact.email);
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