/**
 * @description       : 
 * @author            : Arjun Singh
 * @group             : 
 * @last modified on  : 05-07-2023
 * @last modified by  : Arjun Singh
**/
@isTest
private class ASDAC_TurnstileCaptchaService_Test {
    /**
    * @description 
    * @author Arjun Singh | 05-07-2023 
    **/
    @isTest
    static void testFetchBaseURL() {
        List<String> expectedURLs = new List<String>();
        expectedURLs.add(URL.getOrgDomainUrl().toExternalForm());
        expectedURLs.add(URL.getSalesforceBaseUrl().toExternalForm());
        expectedURLs.add(URL.getOrgDomainUrl().toExternalForm().replace('.my.salesforce.com', '.lightning.force.com'));
        expectedURLs.add(URL.getOrgDomainUrl().toExternalForm().replace('.my.salesforce.com', '--c.visualforce.com'));
        List<String> actualURLs = ASDAC_TurnstileCaptchaService.fetchBaseURL();
        System.assertEquals(expectedURLs, actualURLs, 'Incorrect base URLs fetched');
    }
    /**
    * @description 
    * @author Arjun Singh | 05-07-2023 
    **/
    @isTest
    static void testGetCaptchaSettings() {
        ASDAC_BotProtectionCloudflareCaptcha__mdt actualSettings = ASDAC_TurnstileCaptchaService.getCaptchaSettings();
        System.assertNotEquals(null,actualSettings, 'Incorrect value');
    }
    /**
    * @description 
    * @author Arjun Singh | 05-07-2023 
    **/
    @isTest
    static void testCreateRequest() {
        String expectedToken = 'testToken';
        ASDAC_TurnstileCaptchaService.TurnstileVerifyRequestWrapper reqBody = new ASDAC_TurnstileCaptchaService.TurnstileVerifyRequestWrapper();
        reqBody.response = expectedToken;

        ASDAC_TurnstileCaptchaService service = new ASDAC_TurnstileCaptchaService();
        String actualRequest = service.createRequest(expectedToken);
        String expectedRequest = JSON.serialize(reqBody);
        System.assertEquals(expectedRequest, actualRequest, 'Incorrect request created');
    }
    
    @isTest
    static void testDoCallout() {
        Test.startTest();
        ASDAC_HTTPCalloutServiceMock_Test mockServiceForTurnstile = new ASDAC_HTTPCalloutServiceMock_Test(200, '{ "success": true,"error-codes": [],"challenge_ts": "2022-10-06T00:07:23.274Z", "hostname": "example.com"}');
        Map<String, ASDAC_HTTPCalloutServiceMock_Test> multiMockMap = new Map<String, ASDAC_HTTPCalloutServiceMock_Test>();
        multiMockMap.put('callout:CloudflareTurnstileCaptcha/turnstile/v0/siteverify', mockServiceForTurnstile);
        ASDAC_HTTPCalloutServiceMultiMock_Test multiCalloutMock = new ASDAC_HTTPCalloutServiceMultiMock_Test(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ASDAC_TurnstileCaptchaService.Request captchaReq = new ASDAC_TurnstileCaptchaService.Request();
        captchaReq.token = 'test-token';
        List<ASDAC_TurnstileCaptchaService.Request> reqList= new List<ASDAC_TurnstileCaptchaService.Request>();
		reqList.add(captchaReq);        
        List<ASDAC_TurnstileCaptchaService.Response> captchaResponse = ASDAC_TurnstileCaptchaService.validateCaptcha(reqList);    
        System.assertEquals(true, captchaResponse[0].isValid, 'Site verified');
        Test.stopTest();
    }
    
    @isTest
    static void testDoCalloutFailToken() {
        Test.startTest();
        ASDAC_HTTPCalloutServiceMock_Test mockServiceForTurnstile = new ASDAC_HTTPCalloutServiceMock_Test(200, '{ "success": false,"error-codes": ["invalid-input-response"],"challenge_ts": "2022-10-06T00:07:23.274Z", "hostname": "example.com"}');
        Map<String, ASDAC_HTTPCalloutServiceMock_Test> multiMockMap = new Map<String, ASDAC_HTTPCalloutServiceMock_Test>();
        multiMockMap.put('callout:CloudflareTurnstileCaptcha/turnstile/v0/siteverify', mockServiceForTurnstile);
        ASDAC_HTTPCalloutServiceMultiMock_Test multiCalloutMock = new ASDAC_HTTPCalloutServiceMultiMock_Test(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        
        ASDAC_TurnstileCaptchaService.Request captchaReq = new ASDAC_TurnstileCaptchaService.Request();
        captchaReq.token = 'test-token-fail';
        List<ASDAC_TurnstileCaptchaService.Request> reqList= new List<ASDAC_TurnstileCaptchaService.Request>();
		reqList.add(captchaReq);        
        List<ASDAC_TurnstileCaptchaService.Response> captchaResponse = ASDAC_TurnstileCaptchaService.validateCaptcha(reqList); 
        System.assertEquals(false, captchaResponse[0].isValid, 'invalid token');
        Test.stopTest();
    }
    @isTest
    static void testDoCalloutFailedReq() {
        Test.startTest();
        ASDAC_HTTPCalloutServiceMock_Test mockServiceForTurnstile = new ASDAC_HTTPCalloutServiceMock_Test(500, '{ "success": false,"error-codes": [],"challenge_ts": "2022-10-06T00:07:23.274Z", "hostname": "example.com"}');
        Map<String, ASDAC_HTTPCalloutServiceMock_Test> multiMockMap = new Map<String, ASDAC_HTTPCalloutServiceMock_Test>();
        multiMockMap.put('callout:CloudflareTurnstileCaptcha/turnstile/v0/siteverify', mockServiceForTurnstile);
        ASDAC_HTTPCalloutServiceMultiMock_Test multiCalloutMock = new ASDAC_HTTPCalloutServiceMultiMock_Test(multiMockMap);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        ASDAC_IntegrationUtility.ResultWrapper resultWrap = (ASDAC_IntegrationUtility.ResultWrapper) JSON.deserialize(ASDAC_CalloutUtilityCmpController.getResponseMethod('TurnstileCaptchaVerify', '{"token":""}'), ASDAC_IntegrationUtility.ResultWrapper.class);      
        System.assertEquals(false, resultWrap.isSuccess, 'req fail');
        Test.stopTest();
    }
}