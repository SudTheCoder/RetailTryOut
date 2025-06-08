/************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2024-06-20
* @description                  : Test class for ASDAC_DPMigrationBatch class
**********************************************************************************/
@isTest
public class ASDAC_DPMigrationBatchTest {
    
    static testMethod void testBatchExecution() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User objUser = new User(Alias = 'migus', Email='MigrationUser@gmail.com', LastName='Migration User',  
                                ProfileId = p.Id, UserName='MigrationUser@salesforce.com' ,EmailEncodingKey='UTF-8', 
                                LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Los_Angeles');
        
        insert objUser;
        System.runAs(objUser){
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            Account objAccount = new Account();
            objAccount.Name = 'DG Test';
            objAccount.Loginid__c ='dg@gmail.com';
            insert objAccount;           
            
            Contact objContact = new Contact();
            objContact.LastName = 'DG Test';
            objContact.AccountId = objAccount.Id;
            objContact.Email = 'test.contact@example.com';
            objContact.Has_Active_Pass__c = false;
            objContact.Has_Expired_Pass__c = false;
            insert objContact; 
            
            Asset testAssetActive = new Asset(
                Name = 'Test Asset Active',
                Status = 'Active',
                AccountId = objAccount.id,
                ContactId = objContact.Id,
                IsMigratedSubscription__c = true
            );
            insert testAssetActive;
            
            Asset testAssetExpired = new Asset(
                Name = 'Test Asset Expired',
                Status = 'Expired',
                ContactId = objContact.Id,
                IsMigratedSubscription__c = true
            );
            insert testAssetExpired;
            
            // Start the batch execution
            Test.startTest();
            ASDAC_DPMigrationBatch batchInstance = new ASDAC_DPMigrationBatch();
            Database.executeBatch(batchInstance);
            Test.stopTest();
            
            // Verify results: Query Contact record after batch execution
            Contact updatedContact = [SELECT Id, Has_Active_Pass__c, Has_Expired_Pass__c FROM Contact WHERE Id = :objContact.Id];
            
            // Assert that the Has_Active_Pass__c and Has_Expired_Pass__c fields are updated as expected
            System.assertEquals(true, updatedContact.Has_Active_Pass__c, 'Expected Has_Active_Pass__c to be true');
            System.assertEquals(true, updatedContact.Has_Expired_Pass__c, 'Expected Has_Expired_Pass__c to be true');
        }}
}