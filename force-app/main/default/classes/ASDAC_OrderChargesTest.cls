@isTest
public class ASDAC_OrderChargesTest {
    
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
    static void testASDAC_OrderCharges() {
        User ocsCollBPO = getuserRecord(USER_NAME);
        System.runAs(ocsCollBPO){
            Test.startTest();
            ASDAC_OrderCharges orderCharges= new ASDAC_OrderCharges();
            orderCharges.name='SHIPPING_CHARGE';
            orderCharges.accountingType=  'FLAT_CHARGE';
            orderCharges.category ='Charge';
            orderCharges.amount= 2.92;
            orderCharges.coefficient= 1;
            orderCharges.invoicedAmount= 2.92;
            orderCharges.isRefundable= true;
            orderCharges.referenceId= 'IDSOE040123';
            orderCharges.referenceType ='ShippingId';
            orderCharges.appliesToLines=new List<Integer>{1, 2, 3};
            System.assertEquals('SHIPPING_CHARGE', orderCharges.name);
            System.assertEquals('FLAT_CHARGE', orderCharges.accountingType);
            System.assertEquals('Charge', orderCharges.category);
            System.assertEquals(2.92, orderCharges.amount);
            System.assertEquals(2.92, orderCharges.invoicedAmount);
            System.assertEquals(true, orderCharges.isRefundable);
            System.assertEquals(1, orderCharges.coefficient);
            System.assertEquals('IDSOE040123', orderCharges.referenceId);
            System.assertEquals('ShippingId', orderCharges.referenceType);
            System.assertEquals(new List<Integer>{1, 2, 3}, orderCharges.appliesToLines);
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