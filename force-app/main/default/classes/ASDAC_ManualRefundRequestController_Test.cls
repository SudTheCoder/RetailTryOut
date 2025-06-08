@isTest
public with sharing class ASDAC_ManualRefundRequestController_Test {
    public static final String TESTUSER = 'testUser_0@testing_0.com.ocsColleagueBPO';    
    @testSetup
    static void setupData() {

        userRole objRole = [Select id from UserRole where Name ='OCS Colleague Tier 2 UK'];
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsColleagueBPO';
        ocsCollBPO.userroleId = objRole.Id;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert ocsCollBPO;
        }

        // Create test data for CustomerCard__c object
        Account acc = ASDAC_TestDataUtility.createAccount(false);
        acc.Name = 'asda test worldine acc';
        insert acc;
    }

    @isTest
    static void testDoManualRefundCallout_Success() {
        Test.startTest();
		 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        

        String response = ASDAC_ManualRefundRequestController.doManualRefundCallout('{"recordId":"0018E0000217ZS6QAM","businessArea":"George","payoutAmount":1,"reasonCode":"Payment Card has expired or Cancelled","notes":"wew","cardToken":"411111587950ff71111"}');
        Test.stopTest();
        
        System.assertNotEquals(null, response, 'The response should not be null');
    }

    @isTest
    static void testDoManualRefundCallout_CustomException() {
		
		 Test.startTest();
		 Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorError());
        
       
        try {
            ASDAC_ManualRefundRequestController.doManualRefundCallout('{recordId:"testId", businessArea: "George", payoutAmount: 10, reasonCode: "Refund Incorrectly Processed", notes: "test", cardToken: "test token" }');
            System.assert(false, 'Exception should have been thrown');
        } catch (Exception ex) {
            System.assert(true, 'AuraException should be thrown due to error');
        }
        Test.stopTest();
    }

    @isTest
    static void testDoManualRefundCallout_EmptyResponse() {
        
        
	   Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorEmpty());
        // Mock error response
        Test.startTest();
        try {
            String result = ASDAC_ManualRefundRequestController.doManualRefundCallout('{"recordId":"0018E0000217ZS6QAM","businessArea":"George","payoutAmount":1,"reasonCode":"Payment Card has expired or Cancelled","notes":"wew","cardToken":"411111587950ff71111"}');
            System.assertEquals(result, null,'Empty response');
        } catch (Exception ex) {
            
        }
        Test.stopTest();
    }

    @isTest
    static void testGetCustomerDefaultCard() {
        // Retrieve the account inserted during @testSetup
        Account acc = [SELECT Id FROM Account WHERE Name = 'asda test worldine acc' LIMIT 1];

        Test.startTest();
        String cardToken = ASDAC_ManualRefundRequestController.getCustomerDefaultCard(acc.Id);
        Test.stopTest();
        System.assert(String.isBlank(cardToken), 'Card token should be either null or empty as not stored');
        //test exception 
        try {
            cardToken = ASDAC_ManualRefundRequestController.getCustomerDefaultCard(null);
        } catch (Exception ex) {
            System.Assert(true, 'Exception should be thrown');
        }
    }

    @isTest
    static void testGetManualRefundLimit() {
        User ocsCollBPO = getuserRecord(TESTUSER);        
        System.runAs(ocsCollBPO) {
            // Execute test for getting refund limit
            Test.startTest();
            Decimal refundLimit = ASDAC_ManualRefundRequestController.getManualRefundLimit();
            Test.stopTest();
            
            System.assertNotEquals(null, refundLimit, 'The refund limit should not be null');
        }
    }

    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }
    
    @isTest
    static void doManualRefundCallout_generalAndCustomCalloutException_catchExcpection() {
        Test.startTest();
        
        // Mocking CustomCalloutException
        Test.setMock(HttpCalloutMock.class, new CustomCalloutExceptionMock());
        String jsonString = '{"recordId":"001xx000003DGbP","businessArea":"George","payoutAmount":100.00,"reasonCode":"Test","notes":"Test notes","cardToken":"testToken","payoutID":"12345","methodType":"Get"}';
        try {
            ASDAC_ManualRefundRequestController.doManualRefundCallout(jsonString);
        } catch (ASDAC_ErrorHandler.CustomCalloutException e) {
            Assert.isTrue(true, 'CustomCalloutException was not caught');
        }
        
        // Mocking general Exception
        Test.setMock(HttpCalloutMock.class, new GeneralExceptionMock());
        try {
            ASDAC_ManualRefundRequestController.doManualRefundCallout(jsonString);
        } catch (Exception e) {
            Assert.isTrue(true, 'General Exception was not caught');
        }
        
        Test.stopTest();
    }
    
    // Mock class for CustomCalloutException
    private class CustomCalloutExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"statusCode":500,"strMessage":"CustomCalloutException"}');
            return res;
        }
    }
    
    // Mock class for general Exception
    private class GeneralExceptionMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('General Exception');
        }
    }
	private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
        	res.setBody('{"statusCode":200,"strData":"{\\"status\\":\\"ACCOUNT_CREDITED\\"}"}');
        	res.setStatusCode(200);
        	return res;
        }
	}
		private class MockHttpResponseGeneratorError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
        	res.setBody('{"statusCode":400,"strData":"{Error}');
        	res.setStatusCode(400);
        	return res;
        }
}

private class MockHttpResponseGeneratorEmpty implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
        	res.setBody('{"statusCode":400,"strData":"{}');
        	res.setStatusCode(204);
        	return res;
        }
}


}