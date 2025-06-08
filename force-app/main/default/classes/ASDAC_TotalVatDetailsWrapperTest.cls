@isTest
public class ASDAC_TotalVatDetailsWrapperTest {
    
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
            ASDAC_TotalVatDetailsWrapper wrapper = new ASDAC_TotalVatDetailsWrapper();
            wrapper.totalPrice = 3.00;
            System.assertEquals(3.00, wrapper.totalPrice);
            wrapper.vatRate = 3.00;
            System.assertEquals(3.00, wrapper.vatRate);
            wrapper.exVat = 3.00;
            System.assertEquals(3.00, wrapper.exVat);
            wrapper.vatAmount = 3.00;
            System.assertEquals(3.00, wrapper.vatAmount);
            wrapper.type = 'ABC';
            System.assertEquals('ABC', wrapper.type);
            
            String actualFormattedPrice = wrapper.totalPriceFormatted;
            System.assertEquals('£3.00', actualFormattedPrice);
            String actualexVatFormatted= wrapper.exVatFormatted;
            System.assertEquals('£3.00', actualexVatFormatted);
            String actualvatAmountFormatted= wrapper.vatAmountFormatted;
            System.assertEquals('£3.00',actualvatAmountFormatted);
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