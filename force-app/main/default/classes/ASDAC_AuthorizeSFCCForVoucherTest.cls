@isTest
Private with Sharing class ASDAC_AuthorizeSFCCForVoucherTest {
    
    @isTest    
    static void getMerkelAuthtokenTest(){
        
        Test.setMock(HttpCalloutMock.Class, new ASDAC_AuthorizeSFCCForVoucherMockTest());
        
        String accessToken = ASDAC_AuthorizeSFCCForVoucher.getMerkelAuthToken();
        
        System.assertEquals('f1fY_SmhFU5NgfHgF9VzDyMkuA0', accessToken);
    }
}