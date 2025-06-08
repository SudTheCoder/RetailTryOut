/************************************************************************************
* Class Name	: ASDAC_CleanseDummyData_Test
* Developer	: Sai
* Created Date	: 04/26/2022
* Purpose		: Test class for class ASDAC_CleanseDummyData
* Reference	: ASDAC-642
* **********************************************************************************/
@isTest
public with sharing class ASDAC_CleanseDummyData_Test {
    
    @testSetup static void setUpTestData() {
 		User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + '.ocsColleagueBPO';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + '.ocsColleagueBPO';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPO) {
            Id recordTypeIdaccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BusinessAccount').getRecordTypeId();
            Account account = ASDAC_TestDataUtility.createAccount(false);
            account.ExternalId__c = 'ABCD1234';
            account.RecordTypeId = recordTypeIdaccount;
            insert(account);
            
            Case caseObj = ASDAC_TestDataUtility.createCases(200, false, 'GeneralEnquiry', account.Id)[0];
            insert caseObj; 

            EmailMessage email = new EmailMessage();
            email.FromAddress = 'Test@abc.org';
            email.Incoming = True;
            email.ToAddress= 'Test@xyz.org';
            email.Subject = 'Test email';
            email.HtmlBody = 'Test email body';
            email.ParentId = caseObj.Id; 
            insert email;
            
            Entitlement ent = new Entitlement(); 
            ent.name= 'TestDefault';
            ent.AccountId = account.Id;
            insert ent;
            
            Macro mac = new Macro();
            mac.name='TestMacro';
            insert mac;
            
            QuickText quickTxt = new QuickText();
            quickTxt.name ='TestQuickText';
            quickTxt.Message='hi';
            insert quickTxt;
        }
    }
    
    @isTest
    public static void cleanseDataTest(){
        ASDAC_CleanseDummyData.cleanseData();
        List<Account> listOfAccounts = [SELECT Id FROM Account];
        System.assertEquals(true, listOfAccounts.isEmpty(), 'The accounts are not deleted');
        List<Contact> listOfContacts = [SELECT Id FROM Contact];
        System.assertEquals(true, listOfContacts.isEmpty(), 'The Contact are not deleted');
        List<Case> listOfCases = [SELECT Id FROM Case];
        System.assertEquals(true, listOfCases.isEmpty(), 'The Case are not deleted');
        List<EmailMessage> listOfEmailMessage = [SELECT Id FROM EmailMessage];
        System.assertEquals(true, listOfEmailMessage.isEmpty(), 'The EmailMessage are not deleted');
        List<Entitlement> listOfEntitlement = [SELECT Id FROM Entitlement];
        System.assertEquals(true, listOfEntitlement.isEmpty(), 'The Entitlement are not deleted');
    }
}