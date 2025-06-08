/***********************************************************************************************************
* @author        : Sapient: Dependra Singh
* @date          : 2022-05-27
* @description   : ASDAC_HTTPCalloutService_Test is the test class for HTTPCalloutService class.
**********************************************************************************8*************************/
@isTest
public class ASDAC_HTTPCalloutService_Test {
 
/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Initializing constants
***************************************************************************************************************/ 
    private static final String CUSTOM_METADATA_NAME = 'TestMetadata';
    private static final String RESPONSE_SUCCESS_MESSAGE = 'test response Status Code is equal to RESPONSE_SUCCESS';
    private static final String RESPONSE_BODY_MESSAGE = 'test response body is equal to RESPONSE_BODY';
    private static final String ENDPOINT = 'https://www.test.com';
    private static final String METHOD = 'POST';
    private static final String REQUEST_BODY = '{"input":"Test Input"}';
    private static final String REQUEST_BODY_XML = '<input>Test Input</input>';
    private static final String RESPONSE_BODY = '{"output":"Test Output"}';
    private static final Integer RESPONSE_SUCCESS = 200;
    private static final Integer TIMEOUT = 120000;
    private static final Boolean ISCOMPRESSED = true;
    private static final String KEY1 = 'key1';
    private static final String KEY2 = 'key2';
    private static final String VALUE1 = 'value1';
    private static final String VALUE2 = 'value2';
    private static final String CERTIFICATE = 'Test Certificate';
    public FINAL STATIC String PERSON_ACCOUNT_SAME_EMAIL = 'SameEmail@Pa.com';
    public FINAL STATIC String PERSON_ACCOUNT_EMAIL = 'newGmail@asdatest.co.uk';
    public FINAL STATIC String BPO_USERNAME = 'testUser_0@testing_0.com.colleagueBPO';

    @testsetup
    static void setup() {
        User ocsColleagueTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsColleagueTstUsr.userName = ocsColleagueTstUsr.userName + '.colleagueBPO';
        ocsColleagueTstUsr.FederationIdentifier = ocsColleagueTstUsr.FederationIdentifier + '.colleagueBPO';
        insert ocsColleagueTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsColleagueTstUsr},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsColleagueTstUsr) {
            Account prsnAccEmail = ASDAC_TestDataUtility.createPersonAccount(false);
            prsnAccEmail.FirstName = 'Same Email';
            prsnAccEmail.LastName = 'Person Account';
            prsnAccEmail.PersonEmail = PERSON_ACCOUNT_SAME_EMAIL;
            prsnAccEmail.LoginId__c = PERSON_ACCOUNT_SAME_EMAIL;
            prsnAccEmail.FirstName__pc = prsnAccEmail.FirstName;
            prsnAccEmail.LastName__pc = prsnAccEmail.LastName;
            prsnAccEmail.Phone = '9876543210';
            insert prsnAccEmail;
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Testing with predefined custom metadata record
***************************************************************************************************************/ 
    @isTest
    public static void testWithCustomMetadata() {
        Test.startTest();
        ASDAC_HTTPCalloutServiceMock_Test testMock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
        Test.setMock(HTTPCalloutMock.class, testMock);
        ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService(CUSTOM_METADATA_NAME);
        HTTPResponse testResponse = service.sendRequest();
        System.assertEquals(RESPONSE_SUCCESS, testResponse.getStatusCode(),RESPONSE_SUCCESS_MESSAGE);
        System.assertEquals(RESPONSE_BODY, testResponse.getBody(), RESPONSE_BODY_MESSAGE);
        Test.stopTest();
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Testing with custom metadata record and setting blob as body
***************************************************************************************************************/ 
    @isTest
    public static void testWithCustomMetadataAndBlobInBody() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            ASDAC_HTTPCalloutServiceMock_Test testMock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService(CUSTOM_METADATA_NAME);
            service.setRequestBodyAsBlob(Blob.valueOf(service.getRequestBody()));
            service.setRequestBody('');
            // Calling sendRequest() method and passing HTTPRequest in parameter
            HTTPResponse testResponse = service.sendRequest(service.getRequest());
            System.assertEquals(RESPONSE_SUCCESS, testResponse.getStatusCode(), RESPONSE_SUCCESS_MESSAGE);
            System.assertEquals(RESPONSE_BODY, testResponse.getBody(), RESPONSE_BODY_MESSAGE);
            Test.stopTest();
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Testing with custom metadata record and setting document as body
***************************************************************************************************************/ 
    @isTest
    public static void testWithCustomMetadataAndDocumentInBody() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            ASDAC_HTTPCalloutServiceMock_Test testMock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService(CUSTOM_METADATA_NAME);
            Dom.Document requestDocument = new Dom.Document();
            requestDocument.load(REQUEST_BODY_XML);
            service.setRequestBodyAsDocument(requestDocument);
            service.setRequestBody('');
            HTTPResponse testResponse = service.sendRequest();
            System.assertEquals(RESPONSE_SUCCESS, testResponse.getStatusCode(), RESPONSE_SUCCESS_MESSAGE);
            System.assertEquals(RESPONSE_BODY, testResponse.getBody(), RESPONSE_BODY_MESSAGE);
            Test.stopTest();
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Testing with wrong custom metadata record to cover the custom exception scenario
***************************************************************************************************************/ 
    @isTest
    public static void testWithWrongCustomMetadata() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            try {
                ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService('TestMetadata1');
                System.assertEquals(service != null, true, 'ASDAC_HTTPCalloutService has data.');
            } catch(Exception e) {
                System.assertEquals(ASDAC_HTTPCalloutFrameworkException.CUSTOM_METADATA_NOT_FOUND, e.getMessage(), 'exception message is equal to ASDAC_HTTPCalloutFrameworkException.CUSTOM_METADATA_NOT_FOUND');
            }
            Test.stopTest();
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Testing with custom metadata and wrong certificate to cover the getters and setters for client certificate
***************************************************************************************************************/ 
    @isTest
    public static void testWithCustomMetadataWrongCertificate() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            ASDAC_HTTPCalloutServiceMock_Test testMock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService(CUSTOM_METADATA_NAME);
            service.setRequestCertificate(CERTIFICATE);
            System.assertEquals(CERTIFICATE, service.getRequestCertificate(), 'CERTIFICATE equals service.getRequestCertificate()');
            Test.stopTest();
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Testing without custom metadata
***************************************************************************************************************/ 
    @isTest
    public static void testWithoutCustomMetadata() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            ASDAC_HTTPCalloutServiceMock_Test testMock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            // Initializing service and testing all the getters and setters
            ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService();
            service.setEndpointURL(ENDPOINT);
            System.assertEquals(ENDPOINT, service.getEndpointURL(), 'ENDPOINT equals service.getEndpointURL()');
            service.setRequestMethod(METHOD);
            System.assertEquals(METHOD, service.getRequestMethod(), 'METHOD equals service.getRequestMethod()');
            service.setRequestBody(REQUEST_BODY);
            System.assertEquals(REQUEST_BODY, service.getRequestBody(), 'service body is equal to RESPONSE_BODY');
            service.setRequestBodyAsBlob(Blob.valueOf(REQUEST_BODY));
            System.assertEquals(Blob.valueOf(REQUEST_BODY), service.getRequestBodyAsBlob(), 'service body as blob is equal to blob value RESPONSE_BODY');
            Dom.document requestDocument = new Dom.Document();
            requestDocument.load(REQUEST_BODY_XML);
            service.setRequestBodyAsDocument(requestDocument);
            System.assertEquals(requestDocument, service.getRequestBodyAsDocument(), ' requestDocument is equal to sevise body as document');
            service.setRequestTimeout(TIMEOUT);
            System.assertEquals(TIMEOUT, service.getRequestTimeout(), 'TIMEOUT is equal to service request timeout');
            service.setIsCompressedRequest(ISCOMPRESSED);
            System.assertEquals(ISCOMPRESSED, service.getIsCompressedRequest(), 'ISCOMPRESSED is equal to service compressed request');
            service.setHeaderParameter(KEY1, VALUE1);
            System.assertEquals(VALUE1, service.getHeaderParameter(KEY1), 'VALUE1 is equal to service.getHeaderParameter(KEY1)');
            service.setHeaderParameter(KEY2, VALUE2);
            System.assertEquals(VALUE2, service.getHeaderParameter(KEY2), 'VALUE2 is equal to service.getHeaderParameter(KEY2)');
            service.removeHeaderParameter(KEY2);
            System.assertEquals(null, service.getHeaderParameter(KEY2), 'null is equal to service.getHeaderParameter(KEY1)');
            Map<String, String> headerParams = service.getHeaderParameters();
            System.assertEquals(VALUE1, headerParams.get(KEY1), 'VALUE1 is equal to headerParams.get(KEY1)');
            // Testing the request and response
            HTTPRequest testRequest = service.getRequest();
            System.assertEquals(METHOD, testRequest.getMethod(), 'METHOD is equal to testRequest.getMethod()');
            HTTPResponse testResponse = service.sendRequest();
            System.assertEquals(RESPONSE_SUCCESS, testResponse.getStatusCode(), RESPONSE_SUCCESS_MESSAGE);
            System.assertEquals(RESPONSE_BODY, testResponse.getBody(), RESPONSE_BODY_MESSAGE);
            Test.stopTest();
        }
            
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Testing with custom metadata and multiple requests.Covered the successful request and response
                  Covered the custom exception in the case of wrong endpoint
***************************************************************************************************************/ 
    @isTest
    public static void testWithCustomMetadataMultipleRequests() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            ASDAC_HTTPCalloutServiceMock_Test testMock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
            Test.setMock(HTTPCalloutMock.class, testMock);
            ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService(CUSTOM_METADATA_NAME);
            HTTPResponse testResponse = service.sendRequest();
            System.assertEquals(RESPONSE_SUCCESS, testResponse.getStatusCode(), RESPONSE_SUCCESS_MESSAGE);
            System.assertEquals(RESPONSE_BODY, testResponse.getBody(), RESPONSE_BODY_MESSAGE);
        }
    }

    /**************************************************************************
     Purpose    : method to retrieve the User Record by username                                 
     Parameters : String username
     Returns    : NA                                        
    **************************************************************************/
    private static User getuserRecord(String username) {
        return [SELECT Id FROM User WHERE UserName = :username];
    }

}