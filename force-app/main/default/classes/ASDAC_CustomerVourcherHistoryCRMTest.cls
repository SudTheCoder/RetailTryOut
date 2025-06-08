@isTest
public with sharing class ASDAC_CustomerVourcherHistoryCRMTest {
 
   @testsetup
    static void testSetup(){
        String recTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
        //insert testAccount
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.PersonEmail = 'test10@asdatest.co.uk';
        acc.Recordtypeid=recTypeId;
        acc.Loginid__c ='test10@asdatest.co.uk';
        insert acc;
    }
    
    
    @isTest
    static void getVoucherHistoryServicedataTest(){
        
        // Set up mock data and callout
        Test.setMock(HttpCalloutMock.class, new ASDAC_CustomerVourcherCRMMockTest());
        
        // Call the method being tested
        account acc = [select id,name from account where Loginid__c ='test10@asdatest.co.uk' limit 1];
        
        test.startTest();
        List<object> result = ASDAC_CustomerVourcherHistoryCRM.getVoucherHistoryServicedata(acc.Id);
        test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size());
    }
    
}