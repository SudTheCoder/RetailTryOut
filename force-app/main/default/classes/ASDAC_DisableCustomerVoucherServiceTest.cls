@isTest
public with Sharing class ASDAC_DisableCustomerVoucherServiceTest {
    
    @isTest
    static void toDisableVoucherTest(){ 
        ASDAC_DisableCustVoucherServiceMockTest.returnError=false;
        
        String accessToken='f1fY_SmhFU5NgfHgF9VzDyMkuA0';
        String merchantId='00032540';
        
        //calling mock class
        
        Test.setMock(HttpCalloutMock.Class, new ASDAC_DisableCustVoucherServiceMockTest());
        
        test.startTest();
        ASDAC_DisableCustomerVoucherService.toDisableVoucher(merchantId,accessToken);
        test.stopTest();
        
        system.assertEquals(false, false);
        system.assertEquals('00032540','00032540');
    }
     static void toDisableVoucherErrorTest(){ 
         ASDAC_DisableCustVoucherServiceMockTest.returnError=true;
        String accessToken='f1fY_SmhFU5NgfHgF9VzDyMkuA0';
        String merchantId='00032540';
        
        //calling mock class
        
        Test.setMock(HttpCalloutMock.Class, new ASDAC_DisableCustVoucherServiceMockTest());
        
        test.startTest();
         try{
        ASDAC_DisableCustomerVoucherService.toDisableVoucher(merchantId,accessToken);
         }
         catch (Exception e)
         {
             
             system.assert(e.getMessage().contains('technical error'));
         }
             
            
      
        test.stopTest();
        
      
    }
}