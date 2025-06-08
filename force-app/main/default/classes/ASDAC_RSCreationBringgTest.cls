/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-07-22
* @description                  : Test Class for ASDAC_RSCreationBringg 
* @lastmodifiedBy				: Deepakshi Grover
* last modified date 			: 2023-10-10
**********************************************************************************/
@isTest
public with sharing class ASDAC_RSCreationBringgTest {
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-20
    * @Method Name                  : testsetup
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/
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
            objAsset1.Recurring_Slot_Status__c = '';
            objAsset1.Renewal_Payment_Failed_Counter__c = 1;
            objAsset1.Renewal_Payment_Status__c = 'Initiated';
            objAsset1.Recurring_Slot_Status__c = '';
            insert objAsset1;
        }
    }
    
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-20
    * @Method Name                  : testSendRecurringslotToBringg
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/
    @isTest
    static void testSendRecurringslotToBringg() {
        Asset objInsAsset = [Select id, Recurring_Slot_Status__c, Recurring_Slot_Frequency__c from Asset where Name = 'Test Asset123' limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        List<ASDAC_RSCreationBringg.InputVariables> input = new List<ASDAC_RSCreationBringg.InputVariables>();
        ASDAC_RSCreationBringg.InputVariables inputVariable = new ASDAC_RSCreationBringg.InputVariables();
        inputVariable.strRecurringSlotId = 'Test-123';
        inputVariable.intFrequency = '1';
        inputVariable.recordId = objInsAsset.id;
        input.add(inputVariable);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('task_external_id', inputVariable.strRecurringSlotId);
        gen.writeNumberField('schedule_type', Integer.valueOf(inputVariable.intFrequency));
        gen.writeEndObject();
        String strRequestBody = gen.getAsString();
        ASDAC_RSCreationBringg.doBringgCallout(strRequestBody,inputVariable.recordId);
        Asset objAsset = [Select id, Recurring_Slot_Status__c, Recurring_Slot_Frequency__c from Asset where id =: inputVariable.recordId limit 1];
        objAsset.Recurring_Slot_Template_Id__c = '123';
        update objAsset;
        Test.stopTest();
    }
    
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-20
    * @Method Name                  : testSendRecurringslotBringg
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/
    @isTest
    static void testSendRecurringslotBringg() {
        Asset objInsAsset = [Select id, Recurring_Slot_Status__c, Recurring_Slot_Frequency__c from Asset where Name = 'Test Asset123' limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        Test.startTest();
        List<ASDAC_RSCreationBringg.InputVariables> input = new List<ASDAC_RSCreationBringg.InputVariables>();
        ASDAC_RSCreationBringg.InputVariables inputVariable = new ASDAC_RSCreationBringg.InputVariables();
        inputVariable.strRecurringSlotId = 'test123';
        inputVariable.intFrequency = '1';
        inputVariable.recordId = objInsAsset.id;
        input.add(inputVariable);
        ASDAC_RSCreationBringg.createRecurringSlot(input);
        Test.stopTest();
    }
    
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-20
    * @Method Name                  : testSendRecurringslotBringgNeg
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/
    @isTest
    static void testSendRecurringslotBringgNeg() {
        Asset objInsAsset = [Select id, Recurring_Slot_Status__c, Recurring_Slot_Frequency__c from Asset where Name = 'Test Asset123' limit 1];
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());
        
        Test.startTest();
        List<ASDAC_RSCreationBringg.InputVariables> input = new List<ASDAC_RSCreationBringg.InputVariables>();
        ASDAC_RSCreationBringg.InputVariables inputVariable = new ASDAC_RSCreationBringg.InputVariables();
        inputVariable.strRecurringSlotId = 'test123';
        inputVariable.intFrequency = '1';
        inputVariable.recordId = objInsAsset.id;
        input.add(inputVariable);
        ASDAC_RSCreationBringg.createRecurringSlot(input);
        Test.stopTest();
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
    
    // Mock response - Error
    public class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setBody('{"success":false,"id":null}');
            return response;
        }
    }
}