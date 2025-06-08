/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-09-22
* @Component Type               : Apex Test Class
* @component Name               : ASDAC_RSNullifyBatchTest
* @description                  : ASDAC-15557
* @Modified By                  : Niteesh Kumar
* @Modified Date		        : 2024-09-16
************************************************************************************/
@isTest
public with sharing class ASDAC_RSNullifyBatchTest {
    
    @testsetup
    static void testsetup() {
        Profile objProfile = [Select id,Name from Profile where Name = 'System Administrator'];
        User objUser = new User(Username = 'recurringslot@asdatest.co.uk',ProfileId = objProfile.Id ,Alias = 'test123',Email = 'test123@asdatest.co.uk',EmailEncodingKey = 'UTF-8',LastName = 'McTesty', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',LanguageLocaleKey = 'en_US');
        insert objUser;
        System.runAs(objUser){
            Account objAccount = new Account();
            objAccount.Name = 'DG Test';
            objAccount.Loginid__c ='dg@asdatest.co.uk';
            insert objAccount;           
            
            Contact objContact = new Contact();
            objContact.LastName = 'DG Test';
            objContact.AccountId = objAccount.Id;
            insert objContact; 
            
            Order objOrder = new Order();
            objOrder.AccountId = objAccount.Id;
            objOrder.EffectiveDate = system.today().addYears(1);
            objOrder.Status = 'Draft';
            insert objOrder;
            Product2 objProd = new Product2(Name = 'TestProd1',ItemId__c = 'TEST',NumberOfInstallments__c = 12);
            insert objProd;
            
            Asset objAsset = new Asset();
            objAsset.Name = 'Test Asset123';
            objAsset.Recurring_Slot_Frequency__c = 'Daily';
            objAsset.Recurring_Slot_1__c = Datetime.now().addDays(1);
            objAsset.AccountId = objAccount.Id;
            objAsset.ContactId = objContact.Id;
            objAsset.Recurring_Slot_Template_Id__c = '10';
            objAsset.Recurring_Slot_Status__c = '';
            objAsset.Renewal_Payment_Failed_Counter__c = 1;
            objAsset.Renewal_Payment_Status__c = 'Initiated';
            objAsset.Recurring_Slot_Status__c = 'Active';
            insert objAsset;
            
            Asset objAsset1 = new Asset();
            objAsset1.Name = 'Test Asset1234';
            objAsset1.Recurring_Slot_Frequency__c = 'Daily';
            objAsset1.Recurring_Slot_1__c = Datetime.now().addDays(1);
            objAsset1.AccountId = objAccount.Id;
            objAsset1.ContactId = objContact.Id;
            objAsset1.Recurring_Slot_Template_Id__c = '10';
            objAsset1.Recurring_Slot_Status__c = 'Cancelled';
            objAsset1.Renewal_Payment_Failed_Counter__c = 1;
            objAsset1.Renewal_Payment_Status__c = 'Initiated';
            objAsset1.Recurring_Slot_Status__c = 'Active';
            objAsset1.status = 'Cancelled';
            insert objAsset1;
        } 
    }
    
    @isTest
    static void xmlCalloutBatchTest() {
        Asset objAsset = [Select id,Is_1_skipped__c,Is_2_skipped__c, Is_3_skipped__c,Recurring_Slot_1__c,Recurring_Slot_End__c,Recurring_Slot_Frequency__c,Recurring_Slot_Id__c, Recurring_Slot_Start__c, Recurring_Slot_Status__c,Status, Recurring_Slot_Template_Id__c,seq_counter__c from Asset where name='Test Asset1234' limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
 		System.enqueueJob(new ASDAC_RSNullifyBatch(objAsset)); 
        Test.stopTest();
        
    }
    
    @isTest
    static void xmlCalloutBatchTestNeg() {
        
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());
        
        Test.startTest();
        Asset objAsset = [Select id,Is_1_skipped__c,Is_2_skipped__c, Is_3_skipped__c,Recurring_Slot_1__c,Recurring_Slot_End__c,Recurring_Slot_Frequency__c,Recurring_Slot_Id__c, Recurring_Slot_Start__c, Recurring_Slot_Status__c,Status, Recurring_Slot_Template_Id__c,seq_counter__c from Asset where name='Test Asset1234' limit 1];

        Test.stopTest();
         System.enqueueJob(new ASDAC_RSNullifyBatch(objAsset)); 
        System.assertEquals(String.isNotBlank(objAsset.Recurring_Slot_Status__c),true);
        
    }
    
    // Mock response - Success
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody('{"success":true,"id":680}');
            return response;
        }
    }
    
    //MockResponseError
    public class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"success":false,"id":null}');
            return response;
        }
    }
    
}