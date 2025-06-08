/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2024-08-02
* @description                  : Test class for ASDAC_DPWalmartSubscription
* @lastmodifiedBy				: Deepakshi Grover
* last modified date 			: 2024-08-02
**********************************************************************************/
@isTest
public class ASDAC_DPWalmartSubscriptionTest {

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

			// Create test Asset records
        List<Asset> assets = new List<Asset>();
        for (Integer i = 0; i < 5; i++) {
            Asset asset = new Asset(
                 Name = 'Test Asset Active'+i,
                Status = 'Active',
                AccountId = objAccount.id,
                ContactId = objContact.Id,
                Is_Walmart_Subscription__c = true
            );
            assets.add(asset);
        }
        insert assets;
            
            
            Test.startTest();
        ASDAC_DPWalmartSubscription batch = new ASDAC_DPWalmartSubscription();
        Database.executeBatch(batch, 200);
        Test.stopTest();

        // Step 3: Verify the results

        // Query the assets to verify the flag was updated
        List<Asset> updatedAssets = [SELECT Id, Is_Walmart_Subscription__c FROM Asset WHERE Id IN :assets];
        for (Asset asset : updatedAssets) {
            System.assertEquals(false, asset.Is_Walmart_Subscription__c, 'The Is_Walmart_Subscription__c flag should be updated to false.');
        }
        }}

}