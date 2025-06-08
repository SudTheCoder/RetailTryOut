/******************************************************************************
Name: ASDAC_RetrieveCommsEventsService_Test
===============================================================================
Req: 
ASDAC-2076 See toyou email comms in SFSC
===============================================================================
Purpose: UI for Comms
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Nitish Yadav    		29 Nov 2022    Initial Development
******************************************************************************/
@isTest
public with sharing class ASDAC_RetrieveCommsEventsService_Test {
    public FINAL STATIC String PERSON_ACCOUNT_SAME_EMAIL = 'SameEmail@Pa.com';
    public FINAL STATIC String PERSON_ACCOUNT_EMAIL = 'newGmail@asdatest.co.uk';
    public FINAL STATIC String BPO_USERNAME = 'testUser_0@testing_0.com.colleagueBPO';
	/**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
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
    /**************************************************************************
     Purpose    : test method to test when no duplicates found then insert 
				  Customer record
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/    
    @isTest
    public static void testCommsEvents() {
        User ocsTeamLdrTstUsr = getuserRecord(BPO_USERNAME);
        System.runAs(ocsTeamLdrTstUsr) {  
            Test.startTest();
            String personContactId = [SELECT Id, PersonContactId FROM Account limit 1] ?.PersonContactId;
            ASDAC_HTTPCalloutServiceMock_Test mockServiceForCommsEvents = new ASDAC_HTTPCalloutServiceMock_Test(200, '{"links":{"self":"/v1/customobjectdata/token/c9f79781-019d-4afc-8de2-27b67fd67896/rowset?$page=1"},"requestToken":"c9f79781-019d-4afc-8de2-27b67fd67896","tokenExpireDateUtc":"2022-11-26T11:00:32.12","customObjectId":"6f513df4-1661-ed11-ba3f-f40343e86f50","customObjectKey":"Transactional_Event_Notification_Service","pageSize":2500,"page":1,"count":2,"top":0,"items":[{"keys":{"guid":"fc781638-1671-407e-a785-578de3fb2407"},"values":{"subscriberkey":"0033L00000c3xmIQAQ","subscriberid":"","jobid":"","batchid":"","listid":"","channel":"SMS","subject":"","recipientstatus":"Sent","sender":"Transactional","businessline":"George","messagepreview":"Hi Jayaram, your George order 004432954 is due to be delivered today (2 March 2024) by our delivery partner Evri. For more details go to your George.com order page.","failreasoncode":" ","timestamp":"2024-03-19T13:48:29.175","opentimestamp":"","clicktimestamp":"","bouncetimestamp":""}},{"keys":{"guid":"a2ef2281-e6ec-48e2-9942-c45302e4e91e"},"values":{"subscriberkey":"0033L00000c3xmIQAQ","subscriberid":"124332316","jobid":"258598","batchid":"10","listid":"67","channel":"Email","subject":"Track your George order 004425781","recipientstatus":"Sent","sender":"Transactional","businessline":"George","messagepreview":"https://view.emails.asda.com/?qs=55c6a4f020564643283095823c805a8efe3b72a8e3a4fc28b7271daa71d790d34137b616734dc1b368e7022ffbf6e267e3b32d2707fa3e2257cdea89850b2b2f","failreasoncode":"","timestamp":"2024-04-01T10:18:26.670","opentimestamp":"2024-04-01T10:18:49","clicktimestamp":"2024-04-01T10:18:53","bouncetimestamp":""}}]}}');
            Map<String, ASDAC_HTTPCalloutServiceMock_Test> multiMockMap = new Map<String, ASDAC_HTTPCalloutServiceMock_Test>();
            multiMockMap.put('callout:GetCommsEvents/data/v1/customobjectdata/key/CommsHistory_IntegrationTable/rowset/?$filter=subscriberkey%20eq%20\''+personContactId+'\'%20&$orderBy=timestamp%20DESC', mockServiceForCommsEvents);
            ASDAC_HTTPCalloutServiceMultiMock_Test multiCalloutMock = new ASDAC_HTTPCalloutServiceMultiMock_Test(multiMockMap);
            Test.setMock(HttpCalloutMock.class, multiCalloutMock);
            ASDAC_IntegrationUtility.ResultWrapper resultWrap = (ASDAC_IntegrationUtility.ResultWrapper) JSON.deserialize(ASDAC_CalloutUtilityCmpController.getResponseMethod('GetCommsEvent', '{"recordId":"' + getCustomerRecord(PERSON_ACCOUNT_SAME_EMAIL)[0].Id + '","token":"ABCDE"}'), ASDAC_IntegrationUtility.ResultWrapper.class);
            System.assertEquals(true, resultWrap.isSuccess, 'Comms Received');
            Test.stopTest();
        }
    }

	/**************************************************************************
     Purpose    : method to retrieve Customer record with email                                
     Parameters : String email
     Returns    : NA                                        
    **************************************************************************/
    private static List<Account> getCustomerRecord(String email) {
        return [SELECT Id FROM Account WHERE PersonEmail = :email AND IsPersonAccount = true];
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