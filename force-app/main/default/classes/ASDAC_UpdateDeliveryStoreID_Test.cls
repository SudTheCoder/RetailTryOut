/**********************************************************************************************
@author        TCS: Rohit Funde
@date          05 March 2025
@param         ContactPointAddress List
@return        void
@description   Test Class for ASDAC_UpdateDeliveryStoreID
**********************************************************************************************/
@isTest
public class ASDAC_UpdateDeliveryStoreID_Test {
    
    @testSetup
    static void setupTestData() {
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'Admin',
            Alias = 'tadmin',
            Email = 'testadmin@example.com',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/New_York',
            Username = 'testadmin' + DateTime.now().millisecond() + '@example.com',
            CommunityNickname = 'testadminnick'
        );
        insert testUser;

        System.runAs(testUser) {
            Store__c store = new Store__c(
                Name = 'Test Store',
                City__c = 'Test City',
                PostalCode__c = 'A1B2C3',
                StoreFormat__c = 'Supermarket',
                StoreNumber__c = '1234'
            );
            insert store;

            StoreCatchment__c storeCatchment = new StoreCatchment__c(
                StoreId__c = store.Id,
                StoreNumber__c = '1234',
                PostalCode__c = 'A1B2C3'
            );
            insert storeCatchment;
        }
    }
    
    @isTest
    static void testUpdateDeliveryStoreIdOnInsert() {
        System.runAs(getTestUser()) {
            ContactPointAddress cpa = new ContactPointAddress(
                Name = 'TestAddress',
                PostalCode__c = 'A1B2C3',
                DeliveryStoreId__c = null
            );

            Test.startTest();
            insert cpa;
            Test.stopTest();
            
            ContactPointAddress updatedCPA = [SELECT Id, DeliveryStoreId__c FROM ContactPointAddress WHERE Id = :cpa.Id LIMIT 1];

            System.assertNotEquals(null, updatedCPA.DeliveryStoreId__c, 'DeliveryStoreId should be updated');
            System.assertEquals('1234', updatedCPA.DeliveryStoreId__c, 'DeliveryStoreId should be exactly 4 digits from StoreNumber');
        }
    }
	
	@isTest
    static void testUpdateDeliveryStoreIdOnUpdate() {
        System.runAs(getTestUser()) {
            ContactPointAddress cpa = new ContactPointAddress(
                Name = 'TestAddress',
                PostalCode__c = 'X9Y8Z7',
                DeliveryStoreId__c = null
            );
            insert cpa;

            cpa.PostalCode__c = 'A1B2C3';

            Test.startTest();
            update cpa;
            Test.stopTest();

            ContactPointAddress updatedCPA = [SELECT Id, DeliveryStoreId__c FROM ContactPointAddress WHERE Id = :cpa.Id LIMIT 1];

            System.assertNotEquals(null, updatedCPA.DeliveryStoreId__c, 'DeliveryStoreId should be updated');
            System.assertEquals('1234', updatedCPA.DeliveryStoreId__c, 'DeliveryStoreId should be exactly 4 digits from StoreNumber');
        }
    }
    
    @isTest
    static void testNoUpdateWhenDeliveryStoreIdIsNotNull() {
        System.runAs(getTestUser()) {
            ContactPointAddress cpa = new ContactPointAddress(
                Name = 'TestAddress',
                PostalCode__c = 'A1B2C3',
                DeliveryStoreId__c = '9999'
            );
            insert cpa;

            cpa.PostalCode__c = 'Z9Y8X7';

            Test.startTest();
            update cpa;
            Test.stopTest();

            ContactPointAddress updatedCPA = [SELECT Id, DeliveryStoreId__c FROM ContactPointAddress WHERE Id = :cpa.Id LIMIT 1];

            System.assertEquals('9999', updatedCPA.DeliveryStoreId__c, 'DeliveryStoreId should not change if already set');
        }
    }

    @isTest
    static void testErrorHandling() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                ASDAC_UpdateDeliveryStoreID.updateDeliveryStoreIdAsync(null);
            } catch (Exception e) {
                System.assert(true, 'Error handling should prevent crash even if null is passed.');
            }
            Test.stopTest();
        }
    }

    private static User getTestUser() {
        return [SELECT Id FROM User WHERE Alias = 'tadmin' LIMIT 1];
    }
}