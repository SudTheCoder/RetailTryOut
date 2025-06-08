/*
* Application Name:- HTTPCalloutFramework
* Description:- This is the test class for HTTPCalloutAsyncService class.
*               Test Coverage:- HttpCalloutAsyncService.cls (100%)
* Dependencies:- TestMetadata record in ASDAC_HTTPCalloutConfiguration__mdt
* Contributors:-
*/


@isTest
public class ASDAC_HTTPCalloutAsyncService_Test {

    /*
    * Initializing constants
    */
    private static final String CUSTOM_METADATA_NAME = 'TestMetadata';
    private static final String RESPONSE_BODY = '{"output":"Test Output"}';
    private static final Integer RESPONSE_SUCCESS = 200;
    private static final Integer TIMEOUT = 120;
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
    /*
    * Testing with predefined custom metadata record
    */
    @isTest
    public static void testWithCustomMetadata() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            List<HTTPResponse> mockResponses = new List<HTTPResponse>();
            ASDAC_HTTPCalloutServiceMock_Test mock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
            ASDAC_HTTPCalloutAsyncService service = new ASDAC_HTTPCalloutAsyncService(TIMEOUT, new List<String>{ CUSTOM_METADATA_NAME });
            Continuation con = service.sendRequest('getAsyncCalloutResponse');
            Map<String, HTTPRequest> requests = con.getRequests();
            System.assert(requests.size() == 1,'Request Size is equal to 1');
            for(String requestLabel : service.getRequestLabels()) {
                HTTPRequest request = requests.get(requestLabel);
                HTTPresponse response = mock.respond(request);
                System.assert(request!=null, 'Request is not equal to null');
                System.assert(response!=null, 'Response is not equal to null');
                mockResponses.add(response);
                Test.setContinuationResponse(requestLabel, response);
            }
            List<HTTPResponse> responses = service.getResponse(service.getRequestLabels());
            System.assertEquals(mockResponses[0].getBody(), responses[0].getBody(), 'mockResponse[0] body equals responses[0] body');
            Test.stopTest();
        }
    }

    /*
    * Testing with predefined custom metadata record and no timeout
    */
    @isTest
    public static void testWithCustomMetadataAndNoTimeout() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) { 
            Test.startTest();
            ASDAC_HTTPCalloutAsyncService service = new ASDAC_HTTPCalloutAsyncService(null, new List<String>{ CUSTOM_METADATA_NAME });
            System.assertEquals(120, service.getRequestTimeout(), '120 is eqaual to service.getRequestTimeout() ');
            service.setRequestTimeout(40);
            System.assertEquals(40, service.getRequestTimeout(),'40 is equal to service.getRequestTimeout()');
            service.setContinuationState('Test State');
            System.assertEquals('Test State', service.getContinuationState(), 'Continuation state is equal to Test State');
            Map<String, HTTPRequest> requestMap = service.getRequestMap();
            HTTPRequest request = requestMap.get(CUSTOM_METADATA_NAME);
            System.assertEquals(true, request.getCompressed(), 'request.getCompressed is true');
            request.setCompressed(false);
            requestMap.put(CUSTOM_METADATA_NAME, request);
            service.setRequestMap(requestMap);
            System.assertEquals(false, service.getRequestMap().get(CUSTOM_METADATA_NAME).getCompressed(), 'service.getRequestMap().get(CUSTOM_METADATA_NAME).getCompressed() is false');
            Test.stopTest();
        }
    }

    /*
    * Testing without custom metadata record and request limit exceeded
    */
    @isTest
    public static void testWithoutCustomMetadataRequestLimitExceeded() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) { 
            Test.startTest();
            ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService(CUSTOM_METADATA_NAME);
            try {
                ASDAC_HTTPCalloutAsyncService service1 = new ASDAC_HTTPCalloutAsyncService(TIMEOUT, new List<HTTPRequest>{ service.getRequest(), service.getRequest(), service.getRequest(), service.getRequest() });
                System.assertEquals(service1 != null, true, 'ASDAC_HTTPCalloutAsyncService has some data.');
            } catch(Exception e) {
                System.assertEquals(ASDAC_HTTPCalloutFrameworkException.CONTINUATION_LIMIT_EXCEEDED, e.getMessage(), 'exception message');
            }
            Test.stopTest();
        }
    }

    /*
    * Testing without custom metadata record
    */
    @isTest
    public static void testWithoutCustomMetadata() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) { 
            Test.startTest();
            List<HTTPResponse> mockResponses = new List<HTTPResponse>();
            ASDAC_HTTPCalloutServiceMock_Test mock = new ASDAC_HTTPCalloutServiceMock_Test(RESPONSE_SUCCESS, RESPONSE_BODY);
            ASDAC_HTTPCalloutService service = new ASDAC_HTTPCalloutService(CUSTOM_METADATA_NAME);
            ASDAC_HTTPCalloutAsyncService service1 = new ASDAC_HTTPCalloutAsyncService(TIMEOUT, new List<HTTPRequest>{ service.getRequest(), service.getRequest(), service.getRequest() });
            Continuation con = service1.sendRequest('getAsyncCalloutResponse');
            Map<String, HTTPRequest> requests = con.getRequests();
            System.assert(requests.size() == 3, 'Requests size is equal to 3');
            for(String requestLabel : service1.getRequestLabels()) {
                HTTPRequest request = requests.get(requestLabel);
                HTTPresponse response = mock.respond(request);
                System.assert(request!=null,'Request is not equal to null');
                System.assert(response!=null,'Response is not equal to null');
                mockResponses.add(response);
                Test.setContinuationResponse(requestLabel, response);
            }
            List<HTTPResponse> responses = service1.getResponse(service1.getRequestLabels());
            System.assertEquals(mockResponses[0].getBody(), responses[0].getBody(), 'MockResponse[0] body is equal to responses[0] body');
            System.assertEquals(mockResponses[1].getBody(), responses[1].getBody(), 'MockResponse[1] body is equal to responses[1] body');
            System.assertEquals(mockResponses[2].getBody(), responses[2].getBody(), 'MockResponse[2] body is equal to responses[2] body');
            Test.stopTest();
        }
    }

    /*
    * Testing with predefined custom metadata record and request limit exceeded
    */
    @isTest
    public static void testWithCustomMetadataRequestLimitExceeded() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) { 
            Test.startTest();
            try {
                ASDAC_HTTPCalloutAsyncService service = new ASDAC_HTTPCalloutAsyncService(TIMEOUT, new List<String>{ CUSTOM_METADATA_NAME, CUSTOM_METADATA_NAME, CUSTOM_METADATA_NAME, CUSTOM_METADATA_NAME });
                System.assertEquals(service != null, true, 'ASDAC_HTTPCalloutAsyncService has some data.');
            } catch(Exception e) {
                System.assertEquals(ASDAC_HTTPCalloutFrameworkException.CONTINUATION_LIMIT_EXCEEDED, e.getMessage(), 'exception message');
            }
            Test.stopTest();
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