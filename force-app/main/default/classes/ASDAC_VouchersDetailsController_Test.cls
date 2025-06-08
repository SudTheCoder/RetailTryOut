@IsTest
public with sharing class ASDAC_VouchersDetailsController_Test {
      private static final String CUSTOMER_EMAIL = 'test.customer@asdatest.co.uk';
    @isTest
    public static void testCreateContentNote() {
        // Create a test record
        Account testAccount = new Account(Name = 'Test Account', Loginid__c = CUSTOMER_EMAIL);
        insert testAccount;
       
        String title = 'Test Content Note';
        String content = 'Test Content';
       
        Test.startTest();
        Id contentDocumentLinkId = ASDAC_VouchersDetailsController.createContentNote(title, content, testAccount.Id);
        Test.stopTest();
       
        // Verify the results
        ContentDocumentLink contentDoclnk = [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType,ContentDocument.Title, ContentDocument.LatestPublishedVersion.VersionData FROM ContentDocumentLink WHERE Id = :contentDocumentLinkId];
        ContentVersion contentVersion = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId = :contentDoclnk.ContentDocumentId AND IsLatest = true];
        System.assertEquals(testAccount.Id, contentDoclnk.LinkedEntityId, 'LinkedEntityId should be the test Account Id');
        System.assertEquals(title, contentDoclnk.ContentDocument.Title, 'Content Note title should match');
        System.assertEquals(content, contentVersion.VersionData.toString(), 'Content Note content should match');
        System.assertEquals('I', contentDoclnk.ShareType, 'ShareType should be "I"');
    }
}