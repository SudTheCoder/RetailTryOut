@isTest
public class ASDAC_OrderTotalTest {
    
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
     static void testASDAC_OrderTotal() {
        
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            ASDAC_OrderTotal wrapper = new ASDAC_OrderTotal();
            wrapper.subtotal = 3.00;
            System.assertEquals(3.00, wrapper.subtotal);
            wrapper.tax = 3.00;
            System.assertEquals(3.00, wrapper.tax);
            wrapper.charges = 3.00;
            System.assertEquals(3.00, wrapper.charges);
            wrapper.discounts = 3.00;
            System.assertEquals(3.00, wrapper.discounts);
            wrapper.totalAmount = 3.00;
            System.assertEquals(3.00, wrapper.totalAmount);
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