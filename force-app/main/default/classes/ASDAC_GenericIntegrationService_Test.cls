@isTest
public with sharing class ASDAC_GenericIntegrationService_Test {  

    // Mock HTTP callout class
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"message": "Success"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void testDoCallout() {
        // Register mock callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Create mock metadata record
        ASDAC_IntegrationMetadata__mdt metadata = new ASDAC_IntegrationMetadata__mdt(
            DeveloperName = 'Test_Metadata',
            MasterLabel = 'Test Metadata',
            MethodType__c = 'POST',
            RequestTimeout__c = 120,
            ContentType__c = 'application/json',
            NamedCredential__c = 'Test_Named_Credential',
            EndPointURL__c = '/test/endpoint',
            Source__c = 'TestSource',
            ExternalSystem__c = 'TestSystem',
            X_Correlation_ID__c = false
        );

        // Create test query parameter metadata
        ASDAC_IntegrationQueryParameter__mdt param = new ASDAC_IntegrationQueryParameter__mdt(
            DeveloperName = 'Test_Param',
            MasterLabel = 'Test Param',
            IntegrationMetadata__c = metadata.Id,
            ParameterName__c = 'param1',
            ParameterValue__c = 'value1'
        );

        // Create test header metadata
        ASDAC_Integration_Headers__mdt header = new ASDAC_Integration_Headers__mdt(
            DeveloperName = 'Test_Header',
            MasterLabel = 'Test Header',
            Integration_Metadata__c = metadata.Id,
            Header_Name__c = 'Custom-Header',
            Header_Value__c = 'HeaderValue'
        );

        // Prepare request JSON      
        ASDAC_GenericIntegrationService.RequestWrapper reqWrapper = new ASDAC_GenericIntegrationService.RequestWrapper();
        reqWrapper.params = new List<String>{'param1=value1'};
        reqWrapper.body = '{"key":"value"}';
        String jsonRequest = JSON.serialize(reqWrapper);

        // Instantiate service and call method
        ASDAC_GenericIntegrationService service = new ASDAC_GenericIntegrationService();
        ASDAC_IntegrationUtility.ResultWrapper result = service.doCallout(metadata, jsonRequest);

        // Assertions with messages
        System.assertNotEquals(null, result, 'ResultWrapper should not be null after doCallout execution.');
        System.assertEquals(true, result.isSuccess, 'Expected isSuccess to be true for a 200 response.');
        System.assertEquals(200, result.statusCode, 'Expected status code to be 200 for a successful callout.');
        System.assert(result.strData.contains('Success'), 'Response body should contain Success.');
    }

    @isTest
    static void testCreateRequest() {
        ASDAC_GenericIntegrationService service = new ASDAC_GenericIntegrationService();
        String result = service.createRequest('{"test":"data"}');
        System.assertEquals(null, result, 'createRequest should return null as per current implementation.');
    }
}