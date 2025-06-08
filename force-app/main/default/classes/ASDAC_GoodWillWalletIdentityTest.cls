@isTest
Private with Sharing class ASDAC_GoodWillWalletIdentityTest {
    public FINAL STATIC String BPO_SUFFIX = '.ocsColleagueBPO';
    public FINAL STATIC String strError = 'Error in result';
    public FINAL STATIC String strWallet = '155771653';
    public FINAL STATIC String strGoodwill = 'Goodwill';
    public FINAL STATIC String strUserMail = 'testUser_0@testing_0.com.ocsColleagueBPO';
    Public Static FINAL String REASON_CODE = 'Cancelled Order';
    Public Static FINAL String CONTACT_REASON_LEVEL ='Loyalty & Rewards';
    Public Static FINAL String CONTACT_REASON_LEVEL1 = 'Vouchers';
    Public Static FINAL String STATUS = 'Assigned';
    Public Static FINAL String SUBJECT = 'Goodwill Voucher';
    Public Static FINAL String GEO_BUSINESS_AREA = 'George';
    Public Static FINAL String GHS_BUSINESS_AREA = 'GHS';

    /**************************************************************************
    Method to insert records for the trigger testing.       
    **************************************************************************/
    @testSetup static void createData() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + BPO_SUFFIX;
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + BPO_SUFFIX;
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        User ocsTeamLdrTstUsr = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsTeamLdrTstUsr.userName = ocsTeamLdrTstUsr.userName + '.teamLeaderUK';
        insert ocsTeamLdrTstUsr;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsTeamLdrTstUsr},ASDAC_GlobalConstants.STRING_OCS_TEAMLEAD_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsTeamLdrTstUsr) {
            ASDAC_TestDataUtility.createPersonAccount(true);
        }
    }

    @isTest
    static void testDoWalletIdentity_Exception() {
        // Setup test data with invalid input to force an exception
        Goodwill__c gw = new Goodwill__c(
            BusinessArea__c = null, // This might cause a NullPointerException
            VoucherAmount__c = null,
            ReasonCode__c = null
        );

        Test.startTest();
        try {
            ASDAC_GoodWillWalletIdentity.doWalletIdentity(null, null, gw);
            System.assert(false, 'Expected an AuraException to be thrown');
        } catch (AuraException e) {
            System.assert(e.getMessage() != null, 'Expected an error message in AuraException');
        }
        Test.stopTest();
    }


    @isTest
    static void testGetWalletForGettingVouchers_Exception() {
        Test.startTest();
        String walletId = ASDAC_GoodWillWalletIdentity.getWalletForGettingVouchers('001InvalidId');
        Test.stopTest();
        System.assertEquals(null, walletId, 'Wallet ID should be null when exception is thrown');
    }
    
    @isTest
    static void testDoWalletIdentity() {
        User ocsCollBPO = getuserRecord(strUserMail);
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = CONTACT_REASON_LEVEL;
            cs.ContactReasonLevel2__c = CONTACT_REASON_LEVEL1;
            cs.Status = STATUS;
            cs.Subject = SUBJECT;
            cs.BusinessArea__c =GEO_BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c=GHS_BUSINESS_AREA;
            goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            
            ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '100109451';
        mockMapping.Name = 'Goodwill';
        insert mockMapping;
            // Set up mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new GoodWillWalletIdentityMock());
            // Call the method under test
            test.startTest();
            ASDAC_GoodWillWalletIdentity.doWalletIdentity(objAccount.Id,strGoodwill, goodwillVal);
            String walletId = ASDAC_GoodWillWalletIdentity.getWalletForGettingVouchers(objAccount.Id);
            System.assertEquals(walletId, strWallet, strError); 
            test.stopTest();
        }
    }
    @isTest
    static void testDoWalletIdentity1() {
        User ocsCollBPO = getuserRecord(strUserMail);
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = CONTACT_REASON_LEVEL;
            cs.ContactReasonLevel2__c = CONTACT_REASON_LEVEL1;
            cs.Status = STATUS;
            cs.Subject = SUBJECT;
            cs.BusinessArea__c =GEO_BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c=GHS_BUSINESS_AREA;
            goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            
            ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '100109451';
        mockMapping.Name = 'Goodwill';
        insert mockMapping;
            // Set up mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new GoodWillWalletIdentityMock());
            // Call the method under test
            test.startTest();
            ASDAC_GoodWillWalletIdentity.callGHSVoucher(objAccount.Id,12,strGoodwill,'');
            String walletId = ASDAC_GoodWillWalletIdentity.getWalletForGettingVouchers(objAccount.Id);
            System.assertEquals(walletId, strWallet, strError); 
            test.stopTest();
        }
    }
    
    
    @isTest
    static void testDoWalletCreation() {
        User ocsCollBPO = getuserRecord(strUserMail);
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = CONTACT_REASON_LEVEL;
            cs.ContactReasonLevel2__c = CONTACT_REASON_LEVEL1;
            cs.Status = STATUS;
            cs.Subject = SUBJECT;
            cs.BusinessArea__c =GEO_BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c=GHS_BUSINESS_AREA;
            goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            
            ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '100109451';
        mockMapping.Name = 'Goodwill';
        insert mockMapping;
            // Set up mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new GoodWillWalletCreationMock());
            // Call the method under test
            test.startTest();
            ASDAC_GoodWillWalletIdentity.doWalletIdentity(objAccount.Id,strGoodwill, goodwillVal);
            ASDAC_GoodWillWalletIdentity.ResponseWrapper mockResponse = ASDAC_GoodWillWalletCreation.createWallet(objAccount.PersonContactId, 100,objAccount.Id,REASON_CODE,'Goodwill');
            System.assertEquals(mockResponse.walletId, '161062096', strError);  
            test.stopTest();
        }
    }
    //Test Partial Success
     @isTest
    static void testPartialSuccess() {
        User ocsCollBPO = getuserRecord(strUserMail);
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = CONTACT_REASON_LEVEL;
            cs.ContactReasonLevel2__c = CONTACT_REASON_LEVEL1;
            cs.Status = STATUS;
            cs.Subject = SUBJECT;
            cs.BusinessArea__c =GEO_BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c=GHS_BUSINESS_AREA;
            goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
            mockMapping.Campaign_Id__c = '100109451';
            mockMapping.Name = 'Goodwill';
            insert mockMapping;
            
            String error;
            // Set up mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new ASDAC_GoodWillPartialSuccessMock());
            // Call the method under test
            test.startTest();
            try{
                            ASDAC_GoodWillWalletIdentity.ResponseWrapper response = ASDAC_GoodWillWalletCreation.createWallet(objAccount.PersonContactId, 12, objAccount.Id, REASON_CODE,'Goodwill');
            System.debug('error '+response);
            }catch(exception e){
                error=e.getMessage();
                System.debug(e.getMessage());
            }
           System.assertEquals(error,'eVoucher not created due to a technical error. Please try again.:Campaign not found', strError);  
            test.stopTest();
        }
    }
    //Test error in callout
    //Test Partial Success
     @isTest
    static void testWalletCreationError() {
        User ocsCollBPO = getuserRecord(strUserMail);
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = CONTACT_REASON_LEVEL;
            cs.ContactReasonLevel2__c = CONTACT_REASON_LEVEL1;
            cs.Status = STATUS;
            cs.Subject = SUBJECT;
            cs.BusinessArea__c =GEO_BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c=GHS_BUSINESS_AREA;
            goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            
            ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '100109451';
        mockMapping.Name = 'Goodwill';
        insert mockMapping;
            
            String error;
            // Set up mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new ASDAC_GoodWillErrorMock());
            // Call the method under test
            test.startTest();
            try{
                 ASDAC_GoodWillWalletIdentity.ResponseWrapper response = ASDAC_GoodWillWalletCreation.createWallet(objAccount.PersonContactId, 12, objAccount.Id, REASON_CODE,'Goodwill');
            System.debug('error '+response);
            }catch(exception e){
                error=e.getMessage();
                System.debug(e.getMessage());
            }
           System.assertEquals(error,'eVoucher not created due to a technical error. Please try again. : Resourse not found', strError);  
            test.stopTest();
        }
    }
    
    @isTest
    static void testWalletCreationError500() {
        User ocsCollBPO = getuserRecord(strUserMail);
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = CONTACT_REASON_LEVEL;
            cs.ContactReasonLevel2__c = CONTACT_REASON_LEVEL1;
            cs.Status = STATUS;
            cs.Subject = SUBJECT;
            cs.BusinessArea__c =GEO_BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c=GHS_BUSINESS_AREA;
            goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            
            ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '123';
        mockMapping.Name = 'Goodwill';
        insert mockMapping;
            
            String error;
            // Set up mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new ASDAC_GoodWillErrorMock_Server());
            // Call the method under test
            test.startTest();
            try{
                 ASDAC_GoodWillWalletIdentity.ResponseWrapper response = ASDAC_GoodWillWalletCreation.createWallet(objAccount.PersonContactId, 12, objAccount.Id, REASON_CODE,'Goodwill');
            System.debug('error '+response);
            }catch(exception e){
                error=e.getMessage();
                System.debug(e.getMessage());
            }
           //System.assertEquals(error,'Internal Server Error', strError);  
            test.stopTest();
        }
    }
    
    @isTest
    static void testWalletCreationServerError500() {
        User ocsCollBPO = getuserRecord(strUserMail);
        System.runAs(ocsCollBPO){
            Account objAccount = [Select id,PersonEmail,PersonContactId from Account limit 1 ];
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = CONTACT_REASON_LEVEL;
            cs.ContactReasonLevel2__c = CONTACT_REASON_LEVEL1;
            cs.Status = STATUS;
            cs.Subject = SUBJECT;
            cs.BusinessArea__c =GEO_BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = objAccount.PersonContactId;
            insert cs;
            
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c = objAccount.PersonEmail;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.BusinessArea__c=GHS_BUSINESS_AREA;
            goodwillVal.AccountId__c = objAccount.id;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.ReasonCode__c = REASON_CODE;
            insert goodwillVal;   
            
            ASDAC_Loyalty_Campaign_Mapping__c mockMapping = new ASDAC_Loyalty_Campaign_Mapping__c();
        mockMapping.Campaign_Id__c = '123';
        mockMapping.Name = 'Goodwill';
        insert mockMapping;
            
            String error;
            // Set up mock HTTP callout
            Test.setMock(HttpCalloutMock.class, new ASDAC_GoodWillErrorMock_Server());
            // Call the method under test
            test.startTest();
            try{
                 ASDAC_GoodWillWalletIdentity.ResponseWrapper response = ASDAC_GoodWillWalletIdentity.callEagleEyeForVoucher(objAccount.PersonContactId, 12,'Goodwill',REASON_CODE);
            System.debug('error '+response);
            }catch(exception e){
                error=e.getMessage();
                System.debug(e.getMessage());
            }
           //System.assertEquals(error,'Internal Server Error', strError);  
            test.stopTest();
        }
    }
    
    //Mock class for Partial sucess:
    public class ASDAC_GoodWillPartialSuccessMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(207);
            String body = '{\n'+
                '"walletId": "161921484",\n'+
                '"accounts": {\n'+
                '"campaign": {\n'+
                '"total": 1,\n'+
                '"results": [\n'+
                '{\n'+
                '"errorCode": "NF",\n'+
                '"errorMessage": "Campaign not found"\n'+
                '}\n'+
                '],\n'+
                '"successful": {\n'+
                '"total": 0,\n'+
                '"results": []\n'+
                '},\n'+
                '"failed": {\n'+
                '"total": 1,\n'+
                '"results": [\n'+
                '{\n'+
                '"errorCode": "NF",\n'+
                '"errorMessage": "Campaign not found"\n'+
                '}]}}}}'; 
            response.setBody(body);
            return response;
        }
    }
    //Mock Class for Error 
     public class ASDAC_GoodWillErrorMock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404);
            response.setBody('{"errorMessage":"Resourse not found","errorCode":"NF"}');
            return response;
        }
    }
    
    //Mock Class for Error 
     public class ASDAC_GoodWillErrorMock_Server implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody('{"errorMessage":"Internal Server Error","errorCode":"NF"}');
            return response;
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
    
public class GoodWillWalletCreationMock implements HttpCalloutMock {
    
    public HTTPResponse respond(HTTPRequest request) {
        if(request.getEndpoint().contains('wallet?identity-value')){
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404);
            response.setBody('{"errorMessage":"Resourse not found","errorCode":"NF"}');
            return response;
        }
        else{
            String body = '{"walletId":"161062096","friendlyName":"Radu Popescu Loyalty Wallet","status":"ACTIVE","type":"CONSUMER","state":"DEFAULT","meta":[],"dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","relationships":{"parent":[],"child":[],"associate":[],"donor":[]},"identities":[{"identityId":"145231980","walletId":"161062096","type":"CUSTOMER_ID","friendlyName":null,"value":"823456789","safeValue":null,"secret":null,"dates":{"start":"2023-08-02T10:43:27+00:00","end":null},"meta":[],"state":"DEFAULT","status":"ACTIVE","dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","mobileWallet":"https://demoapi.podifi.com/passbook/identity/108502/161062096/145231980/c61d249e34f9c4f588fc1733debc58ae242f4696a2218de5a093b5a290576444"},{"identityId":"145231981","walletId":"161062096","type":"MEMBERSHIP_ID","friendlyName":null,"value":"9939006707643005","safeValue":null,"secret":null,"dates":{"start":"2023-08-02T10:43:27+00:00","end":null},"meta":[],"state":"DEFAULT","status":"ACTIVE","dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","mobileWallet":"https://demoapi.podifi.com/passbook/identity/108502/161062096/145231981/d909b8ad00f6064ae525328aa3ee6f5cbd7268ee718836c0abe62e99336bc2d7"}],"accounts":{"campaign":{"total":2,"results":[{"accountId":"2260365165","walletId":"161062096","campaignId":"1550173","type":"ECOUPON","clientType":"GOODWILL_VOUCHER","status":"ACTIVE","state":"DEFAULT","dates":{"start":"2023-08-02T10:43:27+00:00","end":"2033-05-02T22:59:00+00:00"},"meta":[],"dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","overrides":{"offer":{"reward":{"discountAmount":20}}},"balances":{"available":0,"refundable":0},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2260365165/6d8ffa48e433efb8125cf6ffc12b920cbc25a2e29ea56656df3e405b7141fd17"},{"accountId":"2260365166","walletId":"161062096","campaignId":"1554564","type":"ECOUPON","clientType":"DEFAULT","status":"ACTIVE","state":"DEFAULT","dates":{"start":"2023-08-02T10:43:27+00:00","end":"2033-05-02T22:59:00+00:00"},"meta":[],"dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","overrides":[],"balances":{"available":0,"refundable":0},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2260365166/c127dab1306cb816435a67a0da8b0838a221ea7dc35cbd5d5bc67f551a5686b1"}],"successful":{"total":2,"results":[{"accountId":"2260365165","walletId":"161062096","campaignId":"1550173","type":"ECOUPON","clientType":"GOODWILL_VOUCHER","status":"ACTIVE","state":"DEFAULT","dates":{"start":"2023-08-02T10:43:27+00:00","end":"2033-05-02T22:59:00+00:00"},"meta":[],"dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","overrides":{"offer":{"reward":{"discountAmount":20}}},"balances":{"available":0,"refundable":0},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2260365165/6d8ffa48e433efb8125cf6ffc12b920cbc25a2e29ea56656df3e405b7141fd17"},{"accountId":"2260365166","walletId":"161062096","campaignId":"1554564","type":"ECOUPON","clientType":"DEFAULT","status":"ACTIVE","state":"DEFAULT","dates":{"start":"2023-08-02T10:43:27+00:00","end":"2033-05-02T22:59:00+00:00"},"meta":[],"dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","overrides":[],"balances":{"available":0,"refundable":0},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2260365166/c127dab1306cb816435a67a0da8b0838a221ea7dc35cbd5d5bc67f551a5686b1"}]},"failed":{"total":0,"results":[]}},"scheme":{"successful":{"results":[{"accountId":"2260365198","walletId":"161062096","campaignId":"1489253","type":"POINTS","clientType":null,"status":"ACTIVE","state":"DEFAULT","dates":{"start":"2023-08-02T10:43:27+00:00","end":"2038-01-19T03:14:07+00:00"},"meta":[],"dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","overrides":[],"balances":{"current":0,"usable":0,"locked":0,"lifetime":0,"lifetimeSpend":0,"lifetimeSpendValue":0,"pending":0},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2260365198/1c2b4864de76215283611980102759aa91b83018d0595a7598aabeb52cf689d4"}],"total":1},"failed":{"results":[],"total":0},"total":1,"results":[{"accountId":"2260365198","walletId":"161062096","campaignId":"1489253","type":"POINTS","clientType":null,"status":"ACTIVE","state":"DEFAULT","dates":{"start":"2023-08-02T10:43:27+00:00","end":"2038-01-19T03:14:07+00:00"},"meta":[],"dateCreated":"2023-08-02T10:43:27+00:00","lastUpdated":"2023-08-02T10:43:27+00:00","overrides":[],"balances":{"current":0,"usable":0,"locked":0,"lifetime":0,"lifetimeSpend":0,"lifetimeSpendValue":0,"pending":0},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2260365198/1c2b4864de76215283611980102759aa91b83018d0595a7598aabeb52cf689d4"}]}}}';
        	// Create a dummy response
        	HttpResponse res = new HttpResponse();
        	res.setHeader('Content-Type', 'application/json');
        	res.setBody(body);
        	res.setStatusCode(201);
        	return res;
            
        }
        
    }

}

Public with Sharing class GoodWillWalletIdentityMock implements HttpCalloutMock {   
    public HttpResponse respond(HttpRequest request){       
         if (request.getEndpoint().contains('wallet?identity-value')) {
             String body = '{\n' +
            '"walletId": "155771653",\n' +
            '"friendlyName": "Asda Loyalty Wallet",\n' +
            '"status": "ACTIVE",\n' +
            '"type": "CONSUMER",\n' +
            '"state": "DEFAULT",\n' +
            '"meta": [],\n' +
            '"dateCreated": "2023-05-18T09:21:35+00:00",\n' +
            '"lastUpdated": "2023-05-18T09:21:35+00:00",\n' +
            '"relationships": {\n' +
            '"parent": [],\n' +
            '"child": [],\n' +
            '"associate": [],\n' +
            '"donor": []\n' +
            '}\n' +
            '}';
        
        		String strHash = '985c17ab08a71a84b37a87c884902b504768465eaf08bf3030ad008aef0321e5';
        
        		HttpResponse response = new HttpResponse();
        
        		response.setBody(body);
        		response.setHeader('Content-Type', 'application/json');
        		response.setHeader('X-EES-AUTH-HASH', strHash);
        		response.setStatusCode(200);
       			return response;
             	
         } else {
             	String body = '{"accountId":"2258840668","walletId":"161046807","campaignId":"1570323","type":"ECOUPON","clientType":"GOODWILL_VOUCHER","status":"ACTIVE","state":"UNLOADED","dates":{"start":"2023-08-02T09:49:49+00:00","end":"2023-10-31T23:59:59+00:00"},"meta":[],"dateCreated":"2023-08-02T09:49:49+00:00","lastUpdated":"2023-08-02T09:49:49+00:00","overrides":{"offer":{"reward":{"creditAmount":17}}},"balances":{"available":17,"refundable":17},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2258840668/d3ae5c6904b7649c274991af69ef1f99ab343330f07e10e5d6f143c6292d8961"}';
             	HttpResponse response = new HttpResponse();	
             	response.setBody(body);
        		response.setHeader('Content-Type', 'application/json');
        		response.setStatusCode(201);
       			return response;
                
            }      
    	}
	}
}