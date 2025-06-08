@isTest
public with Sharing class ASDAC_CustomerVoucherHistoryServiceTest {
    
    
    @testsetup
    static void testSetup(){
        
        //insert testAccount
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.PersonEmail = 'test10@asdatest.co.uk';
        acc.Loginid__c ='test10@asdatest.co.uk';
        insert acc;
    }
    
    
    @isTest
    static void getVoucherHistoryServicedataTest(){
        
        // Set up mock data and callout
        Test.setMock(HttpCalloutMock.class, new CustomerVoucherHistoryServiceMock());
        
        // Call the method being tested
        String access_token = 'f1fY_SmhFU5NgfHgF9VzDyMkuA0';
        account acc = [select id,name from account where Loginid__c ='test10@asdatest.co.uk' limit 1];
        
        test.startTest();
        List<object> result = ASDAC_CustomerVoucherHistoryService.getVoucherHistoryServicedata(access_token, acc.Id);
        test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size());
        ASDAC_CustomerVoucherHistoryService.responsevalue resVal = (ASDAC_CustomerVoucherHistoryService.responsevalue) result[0];
        
        System.assertEquals('issued', resVal.status);
        System.assertEquals(110, resVal.balanceValue);
        System.assertEquals(true, resVal.enabled);
        System.assertEquals('00032540', resVal.merchantId);
        System.assertNotEquals('OMS', resVal.sender_name);
    }


public class CustomerVoucherHistoryServiceMock implements HttpCalloutMock {
	
    public HttpResponse respond(HttpRequest request){
        
        String accesstoken = 'f1fY_SmhFU5NgfHgF9VzDyMkuA0';
        
        String body=	'{\n"_v": "22.10",\n'+
            			'"_type": "gift_certificate_search_result",\n'+
            			'"count": 1,\n'+
            			'"hits": [\n'+
            			'{\n'+
            			'"balance": {\n'+
            			'"value": 110.00\n'+
            			'},\n'+
            			'"creation_date": "2023-03-28T16:37:28.000Z",\n'+
            			'"description": "my-description",\n'+
            			'"enabled": true,\n'+
            			'"masked_gift_certificate_code": "************HRMH",\n'+
            			'"merchant_id": "00032540",\n'+
            			'"sender_name": "OMS",\n'+
            			'"status": "issued",\n'+
            			'"c_expiryDate": "2022-11-01T13:17:56.000Z"\n'+
            			'}\n'+
              			']\n'+
             			'}';
        
        HttpResponse response = new HttpResponse();
        
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Authorization', 'Bearer '+ accesstoken);
        response.setStatusCode(200);
        return response;
    }
}
}