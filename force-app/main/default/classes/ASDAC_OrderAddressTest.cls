@isTest
public class ASDAC_OrderAddressTest {
    
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
    static void testASDAC_OrderAddress() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            Test.startTest();
            ASDAC_OrderAddress orderAddress = new ASDAC_OrderAddress();
            orderAddress.addressLine1 = '123 Test Street';
            orderAddress.addressLine2 = 'Suite 456';
            orderAddress.city = 'Test City';
            orderAddress.state = 'Test State';
            orderAddress.country = 'Test Country';
            orderAddress.zipCode = '12345';
            orderAddress.latitude = 37.7749;
            orderAddress.longitude = -122.4194;
    
            System.assertEquals('123 Test Street', orderAddress.addressLine1);
            System.assertEquals('Suite 456', orderAddress.addressLine2);
            System.assertEquals('Test City', orderAddress.city);
            System.assertEquals('Test State', orderAddress.state);
            System.assertEquals('Test Country', orderAddress.country);
            System.assertEquals('12345', orderAddress.zipCode);
            System.assertEquals(37.7749, orderAddress.latitude);
            System.assertEquals(-122.4194, orderAddress.longitude);
            Test.stopTest();
        }
    }
    
     @isTest
    static void testASDAC_OrderAddressInfo() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            Test.startTest();
            ASDAC_OrderAddressInfo addressInfo = new ASDAC_OrderAddressInfo();
            addressInfo.id = '82ad8b9d-bdde-4f9d-946c-a45bc40d7d13';
            addressInfo.isDefault = false;
            addressInfo.type = 'billTo';
            addressInfo.isActive = true;
    
            System.assertEquals('82ad8b9d-bdde-4f9d-946c-a45bc40d7d13', addressInfo.id);
            System.assertEquals(false, addressInfo.isDefault);
            System.assertEquals('billTo', addressInfo.type);
            System.assertEquals(true, addressInfo.isActive);
            Test.stopTest();
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