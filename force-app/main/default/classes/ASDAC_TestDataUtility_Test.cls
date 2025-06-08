/***************************************************************************************************************************
* Author:       Ramdev Chahar
* Date:         27/06/2022
* Description:  Test Class For ASDAC_TestDataUtility Class
**************************************************************************************************************************/
@IsTest
public with sharing class ASDAC_TestDataUtility_Test {   
    static final String STRING_CONST = '.ocsColleagueBPO'; 
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createAccountWithContacts
    **************************************************************************************************************************/
    @isTest
    static void testCreateAccountWithContacts() {
         User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + STRING_CONST;
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + STRING_CONST;
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        ASDAC_TestDataUtility.createPermissionSetAssignment(new List<User>{ocsCollBPO}, 'ASDA_Manage_Stakelholders');
        System.runAs(ocsCollBPO) {
        ASDAC_TestDataUtility.createAccountWithContacts(1,1);
        }
         // Add assertions to verify the expected behavior
        Integer accountCount = [SELECT COUNT() FROM Account];
        Integer contactCount = [SELECT COUNT() FROM Contact];
        
        System.assertEquals(1, accountCount, 'Expected 1 Account record to be created');
        System.assertEquals(1, contactCount, 'Expected 1 Contact record to be created');
        
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createAccount
    **************************************************************************************************************************/
    @isTest
    static void testCreateAccount() {
        test.startTest();
        Account createdAccount= ASDAC_TestDataUtility.createAccount(true);
        test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertNotEquals(null, createdAccount.Id, 'Expected Account record to be created');
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createPersonAccount
    **************************************************************************************************************************/
    @isTest
    static void testCreatePersonAccount() {
        test.startTest();
        Account createdPersonAccount = ASDAC_TestDataUtility.createPersonAccount(true);
        test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertNotEquals(null, createdPersonAccount.Id, 'Expected Person Account record to be created');
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createContact
    **************************************************************************************************************************/
    @isTest
    static void testCreateContact() {
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsCollBPO.userName = ocsCollBPO.userName + STRING_CONST;
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + STRING_CONST;
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        ASDAC_TestDataUtility.createPermissionSetAssignment(new List<User>{ocsCollBPO}, 'ASDA_Manage_Stakelholders');
        
         System.runAs(ocsCollBPO) {
            Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('BusinessAccount').getRecordTypeId();
            Account account = ASDAC_TestDataUtility.createAccount(false);
            account.ExternalId__c = 'ABCD1234';
            account.RecordTypeId = recordTypeIdAccount;
            Database.insert(account);
            
            Contact contact = ASDAC_TestDataUtility.createContact(false,account.Id);
            Database.insert(contact);

             // Add assertions to verify the expected behavior
            System.assertNotEquals(null, account.Id, 'Expected Account record to be created');
            System.assertNotEquals(null, contact.Id, 'Expected Contact record to be created');
        }
    }
    
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For getProfile
    **************************************************************************************************************************/
    @isTest
    static void testGetProfile() {
        test.startTest();
        Profile adminProfile = ASDAC_TestDataUtility.getProfile('System Administrator');
        test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertNotEquals(null, adminProfile, 'Expected System Administrator profile to be retrieved');
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For getUser
    **************************************************************************************************************************/
    @isTest
    static void testGetUser() {
        String username = (System.URL.getSalesforceBaseUrl()+'').Split('//')[1]+'test@asdatest.co.uk';
        Id profileId = UserInfo.getProfileId();
        User retrievedUser; // Declare the retrievedUser variable
        test.startTest();
        retrievedUser = ASDAC_TestDataUtility.getUser(username,profileId);
        test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertNotEquals(null, retrievedUser, 'Expected User to be retrieved');
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createContactPointAddress
    **************************************************************************************************************************/
    @isTest
    static void testCreateContactPointAddress() {
        test.startTest();
        List<ContactPointAddress> createdAddresses = ASDAC_TestDataUtility.createContactPointAddress(true, ASDAC_TestDataUtility.createPersonAccount(true).Id, 1);
        test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertEquals(1, createdAddresses.size(), 'Expected a single ContactPointAddress__c record to be created');
        System.assertNotEquals(null, createdAddresses[0].Id, 'Expected ContactPointAddress__c record to have a valid Id');
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createContactPointConsent
    **************************************************************************************************************************/
    @isTest
    static void testCreateContactPointConsent() {
        Id accId = ASDAC_TestDataUtility.createPersonAccount(true).Id;
        Id conId = ASDAC_TestDataUtility.createContactPointPhone(true, accId, 1)[0].Id;
        test.startTest();
        List<ContactPointConsent> createdConsents = ASDAC_TestDataUtility.createContactPointConsents(true, accId, conId, 1);
        test.stopTest();

        // Add assertions to verify the expected behavior
        System.assertEquals(1, createdConsents.size(), 'Expected a single ContactPointConsent__c record to be created');
        System.assertNotEquals(null, createdConsents[0].Id, 'Expected ContactPointConsent__c record to have a valid Id');
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createContactPointPhone
    **************************************************************************************************************************/
    @isTest
    static void testCreateContactPointPhone() {
        test.startTest();
        List<ContactPointPhone> createdPhones = ASDAC_TestDataUtility.createContactPointPhone(true, ASDAC_TestDataUtility.createPersonAccount(true).Id, 1);
        test.stopTest();

         // Add assertions to verify the expected behavior
        System.assertEquals(1, createdPhones.size(), 'Expected a single ContactPointPhone__c record to be created');
        System.assertNotEquals(null, createdPhones[0].Id, 'Expected ContactPointPhone__c record to have a valid Id');
    }
    /***************************************************************************************************************************
    * Author:       Ramdev Chahar
    * Date:         27/06/2022
    * Description:  Test Method For createContactPointEmail
    **************************************************************************************************************************/
    @isTest
    static void testCreateContactPointEmail() {
        test.startTest();
        List<ContactPointEmail> createdEmails = ASDAC_TestDataUtility.createContactPointEmail(true, ASDAC_TestDataUtility.createPersonAccount(true).Id, 1);
        test.stopTest();

         // Add assertions to verify the expected behavior
        System.assertEquals(1, createdEmails.size(), 'Expected a single ContactPointEmail__c record to be created');
        System.assertNotEquals(null, createdEmails[0].Id, 'Expected ContactPointEmail__c record to have a valid Id');
    }
    
}