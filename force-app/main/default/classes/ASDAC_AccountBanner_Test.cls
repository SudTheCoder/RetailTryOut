@isTest
public class ASDAC_AccountBanner_Test {
    
    @isTest
    static void testASDAC_AccountBanner() {
        // Create a test Account record
        Account testAccount = new Account(Name = 'Test Account', Loginid__c='test@c.com', SuspendedDate__c = Date.today(), UnderAuditDatetime__c = DateTime.now());
        insert testAccount;
        
        Test.startTest();
        PageReference pageRef = Page.ASDAC_AccountSuspensionBanner;
        pageRef.getParameters().put('id', testAccount.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testAccount);
        ASDAC_AccountBanner controllerInstance = new ASDAC_AccountBanner(stdController);
        Account accountRecord = controllerInstance.accObj;
        System.assertEquals('Test Account', accountRecord.Name);
        Test.stopTest();
    }
}