/**********************************************************************************
 * @author                       : Deepakshi Grover
 * @date                         : 2023-03-17
 * @Component Type               : Apex Class
 * @component Name               : ASDAC_XMLCalloutBatchTest
 * @description                  : ASDAC-8013 - GHS - DP SME - Auto Renewal
 * @Modified By                  : Deepakshi
 * @Modified Date		         : 2023-03-07
 ***************************************************************************************************/
@isTest
public with sharing class ASDAC_XMLCalloutBatchTest {
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
            
            Asset objAsset = new Asset();
            objAsset.Name = 'Test Asset123';
            objAsset.Recurring_Slot_Frequency__c = 'Daily';
            objAsset.Recurring_Slot_1__c = Datetime.now().addDays(1);
            objAsset.AccountId = objAccount.Id;
            objAsset.ContactId = objContact.Id;
            insert objAsset;
            
        }  
    }
    
     @isTest
    static void xmlCalloutBatchTest() {
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
         Test.setMock(HttpCalloutMock.class, new ASDAC_XMLCalloutMockTest());
        System.runAs(objUser){
            Asset objAsset = [Select id,name from Asset where name='Test Asset123' limit 1];
            String strXML = '<?xml version="1.0" encoding="UTF-8"?><orders xmlns="http://www.demandware.com/xml/impex/order/2006-10-31"><order order-no="00002205"><order-date>2023-01-05T14:31:09.000Z</order-date><created-by>storefront</created-by><original-order-no>00002205</original-order-no><currency>GBP</currency><customer-locale>en_US</customer-locale><taxation>gross</taxation><invoice-no>00003502</invoice-no></order></orders>';
            Map<Id,String> mapXML = new Map<Id,String>();
            mapXML.put(objAsset.Id, strXML);
            Test.startTest();
            ASDAC_XMLCalloutBatch objCallout = new ASDAC_XMLCalloutBatch(mapXML,'AutoRenew');
            Database.executeBatch(objCallout,1);
            Test.stopTest();
        }
    }
    
     @isTest
    static void xmlMonthlyPaymentCalloutBatchTest() {
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
         Test.setMock(HttpCalloutMock.class, new ASDAC_XMLCalloutMockTest());
        System.runAs(objUser){
            Asset objAsset = [Select id,name from Asset where name='Test Asset123' limit 1];
            String strXML = '<?xml version="1.0" encoding="UTF-8"?><orders xmlns="http://www.demandware.com/xml/impex/order/2006-10-31"><order order-no="00002205"><order-date>2023-01-05T14:31:09.000Z</order-date><created-by>storefront</created-by><original-order-no>00002205</original-order-no><currency>GBP</currency><customer-locale>en_US</customer-locale><taxation>gross</taxation><invoice-no>00003502</invoice-no></order></orders>';
            Map<Id,String> mapXML = new Map<Id,String>();
            mapXML.put(objAsset.Id, strXML);
            Test.startTest();
            ASDAC_XMLCalloutBatch objCallout = new ASDAC_XMLCalloutBatch(mapXML,'Monthly');
            Database.executeBatch(objCallout,1);
            Test.stopTest();
        }
    }

}