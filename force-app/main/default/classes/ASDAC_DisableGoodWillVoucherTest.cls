@isTest
private with sharing class ASDAC_DisableGoodWillVoucherTest {
    
    @istest
    static void doDisableTest(){
        
        String voucherId = '2052606622';
        String walletId = '155819274';
        Test.setMock(HttpCalloutMock.class, new DisableGoodWillVoucherMock());
        Test.startTest();
        try{
            ASDAC_DisableGoodWillVoucher.doDisableVoucher(walletId, voucherId);
       }catch(Exception e){
           System.debug('Error : '+e.getMessage());
       }
        System.assertEquals(voucherId, '2052606622','Error!');
        Test.stopTest();
    }
    
    @istest
    static void doDisableErrorTest(){       
        String voucherId = '2052606622';
        String walletId = '155819274';
        Test.setMock(HttpCalloutMock.class, new DisableGoodWillVoucherErrorMock());
        Test.startTest();
        try{
             ASDAC_DisableGoodWillVoucher.doDisableVoucher(walletId, voucherId);
        }catch(Exception e){
            System.debug('Error : '+e.getMessage());
        }
        
        System.assertEquals(voucherId, '2052606622','Error in Callout!');
        Test.stopTest();
    }
        // Mock response - success
    public class DisableGoodWillVoucherMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
        String responseBody = '{"status": "CANCELLED"}'	;
        HttpResponse response = new HttpResponse();
        response.setBody(responseBody);
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        return response;
        }
    }
      // Mock response - Error
    public class DisableGoodWillVoucherErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
        String responseBody = '{"errorMessage": "Access denied due to invalid subscription Key","errorCode": "401"}'	;
        HttpResponse response = new HttpResponse();
        response.setBody(responseBody);
        response.setStatusCode(401);
        response.setHeader('Content-Type', 'application/json');
        return response;
        }
    }
}