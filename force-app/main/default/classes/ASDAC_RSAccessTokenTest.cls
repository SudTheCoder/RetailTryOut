/**********************************************************************************
* @author                       : Deepakshi Grover
* @Createddate                  : 2023-10-10
* @description                  : Test Class for ASDAC_RSAccessToken 
* @lastmodifiedBy				: Naseer Syed
* last modified date 			: 2025-28-04
**********************************************************************************/
@isTest
public class ASDAC_RSAccessTokenTest {

    @testSetup
    static void testsetup() {
        Profile objProfile = [Select id,Name from Profile where Name = 'System Administrator'];
        User objUser = new User(Username = 'recurringslot@test.com',ProfileId = objProfile.Id ,Alias = 'test123',Email = 'test123@test.com',EmailEncodingKey = 'UTF-8',LastName = 'McTesty', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',LanguageLocaleKey = 'en_US');
        insert objUser;
        System.runAs(objUser){
            // Create test data for the custom metadata types
        ASDAC_LoyaltyPaymentAuth__mdt authDetails = new ASDAC_LoyaltyPaymentAuth__mdt();
        authDetails.MasterLabel = 'test_Interface';
        authDetails.apiKey__c = 'test_api_key';
        authDetails.apiSecret__c = 'test_api_secret';
        authDetails.pspId__c = 'test_scope';

        ASDAC_Loyalty_base_urls__mdt monthlyPayTokenUrl = new ASDAC_Loyalty_base_urls__mdt();
        monthlyPayTokenUrl.MasterLabel = 'test_monthlypayment';
        monthlyPayTokenUrl.Traget_endpoint__c = 'https://test-endpoint.com/token';
        }
    }
    // Test scenario for a successful HTTP callout response.
    @isTest
    static void testGetAccessTokenSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockHttpSuccessResponseGenerator());
        User testUser = [SELECT Id FROM User WHERE Username = 'recurringslot@test.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                List<ASDAC_RSAccessToken.OutputWrapper> result = ASDAC_RSAccessToken.getAccessToken();
            Test.stopTest();
            System.assertNotEquals(null, result, 'Output list should not be null for a successful response.');
            System.assertEquals(1, result.size(), 'Expected one OutputWrapper record.');
            System.assertEquals('sampleAccessToken', result[0].access_token, 'Access token should match the mocked value.');
        }
    }
    // Test scenario for a valid error response that does not trigger an exception.
    @isTest
    static void testGetAccessTokenErrorValidJSON() {
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());
        User testUser = [SELECT Id FROM User WHERE Username = 'recurringslot@test.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                List<ASDAC_RSAccessToken.OutputWrapper> result = ASDAC_RSAccessToken.getAccessToken();
            Test.stopTest();
            System.assertNotEquals(null, result, 'Result list should not be null, even in error.');
            System.assertEquals(1, result.size(), 'Error branch expects one record to have been added.');
            System.assertEquals(null, result[0].access_token, 'The access token should be null when not provided in the response.');
        }
    }
    // Test scenario forcing an exception by returning invalid JSON.
    @isTest
    static void testGetAccessTokenException() {
        Test.setMock(HttpCalloutMock.class, new MockHttpInvalidJSONResponseGenerator());
        User testUser = [SELECT Id FROM User WHERE Username = 'recurringslot@test.com' LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
                List<ASDAC_RSAccessToken.OutputWrapper> result = ASDAC_RSAccessToken.getAccessToken();
            Test.stopTest();
            System.assertEquals(null, result, 'On exception, the method should return null.');
        }
    }
    // Returns a valid JSON response with an access token.
    public class MockHttpSuccessResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "sampleAccessToken"}');
            return res;
        }
    }
    // Returns a valid JSON error response without an access token.
    public class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Error occurred during the callout"}');
            return res;
        }
    }
    // Returns invalid JSON to force an exception during JSON deserialization.
    public class MockHttpInvalidJSONResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('INVALID JSON');
            return res;
        }
    }
}