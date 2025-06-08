@isTest
public class ASDAC_RewardsIntegrationServiceTest {

    // Mock HttpCallout Implementation for Successful Callout Response
    private class MockHttpCalloutSuccess implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('Successful');
            return res;
        }
    }
    // Mock HttpCallout Implementation for Failed Callout Response
    private class MockHttpCalloutFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('Error Occurred');
            return res;
        }
    }
    // Test Method: Successful Callout using doCallout() method
    @isTest
    static void testDoCallout_Success() {
        // Create an in-memory instance of integration metadata.
        ASDAC_IntegrationMetadata__mdt integrationMeta = new ASDAC_IntegrationMetadata__mdt(
            MethodType__c       = 'POST',
            RequestTimeout__c   = 10000,
            ContentType__c      = 'application/json',
            NamedCredential__c  = 'Mock_Named_Credential',
            EndPointURL__c      = '/mockEndpoint',
            X_Correlation_ID__c = false,
            Source__c           = 'TestSource',
            ExternalSystem__c   = 'TestExternal'
        );
        
        // Prepare a valid JSON input.
        String jsonInput = '{"crmId": "12345", "params": ["param1"], "body": "test body"}';    
        // Set the HTTP callout mock to simulate a success response.
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutSuccess());
       
        Test.startTest();
            ASDAC_RewardsIntegrationService service = new ASDAC_RewardsIntegrationService();
            ASDAC_IntegrationUtility.ResultWrapper result = service.doCallout(integrationMeta, jsonInput);
        Test.stopTest();
        
        // Validate that the result is as expected.
        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assertEquals(true, result.isSuccess, 'Callout should be successful.');
        System.assertEquals(200, result.statusCode, 'Status code should be 200.');
        System.assertEquals('Successful', result.strData, 'Response body did not match.');
    }
    // Test Method: Failed Callout using doCallout() method
    @isTest
    static void testDoCallout_Failure() {
        // Create an in-memory instance of integration metadata.
        ASDAC_IntegrationMetadata__mdt integrationMeta = new ASDAC_IntegrationMetadata__mdt(
            MethodType__c       = 'POST',
            RequestTimeout__c   = 10000,
            ContentType__c      = 'application/json',
            NamedCredential__c  = 'Mock_Named_Credential',
            EndPointURL__c      = '/mockEndpoint',
            X_Correlation_ID__c = false,
            Source__c           = 'TestSource',
            ExternalSystem__c   = 'TestExternal'
        );
        
        // Preparing a valid JSON input.
        String jsonInput = '{"crmId": "12345", "params": ["param1"], "body": "test body"}';
        // Setting the HTTP callout mock to simulate a failure response.
        Test.setMock(HttpCalloutMock.class, new MockHttpCalloutFailure());
        
        Test.startTest();
            ASDAC_RewardsIntegrationService service = new ASDAC_RewardsIntegrationService();
            ASDAC_IntegrationUtility.ResultWrapper result = service.doCallout(integrationMeta, jsonInput);
        Test.stopTest();
        
        // Validate that the failure result is as expected.
        System.assertNotEquals(null, result, 'Result should not be null even in failure cases.');
        System.assertEquals(false, result.isSuccess, 'Callout should have failed.');
        System.assertEquals(500, result.statusCode, 'Status code should be 500.');
        System.assertEquals('Error Occurred', result.strData, 'Response body did not match the expected error.');
    }
    // Test Method for createRequest Method
    @isTest
    static void testCreateRequest() {
        ASDAC_RewardsIntegrationService service = new ASDAC_RewardsIntegrationService();
        String result = service.createRequest('{"test":"data"}');
        System.assertEquals(null, result, 'createRequest should return null as it is currently a stub.');
    }
    // Test Method: Rewardswrapper.toIntegrationWrapper() Inner Method
    @isTest
    static void testRewardsWrapperToIntegrationWrapper() {
        // Instantiate the inner Rewardswrapper class.
        ASDAC_RewardsIntegrationService.Rewardswrapper rewardsWrapper =
            new ASDAC_RewardsIntegrationService.Rewardswrapper();
        rewardsWrapper.crmId = 'crmTest';
        rewardsWrapper.body = 'Sample body';
        rewardsWrapper.params = new List<String>{ 'param1', 'param2' }; 
        // Call the inner method.
        ASDAC_IntegrationUtility.IntegrationWrapper intWrapper = rewardsWrapper.toIntegrationWrapper();
        // Validate that the returned IntegrationWrapper is not null.
        System.assertNotEquals(null, intWrapper, 'toIntegrationWrapper() should return a non-null IntegrationWrapper instance.');
    }
}