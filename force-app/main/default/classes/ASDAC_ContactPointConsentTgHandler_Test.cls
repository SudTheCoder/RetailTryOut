@IsTest
public class ASDAC_ContactPointConsentTgHandler_Test {
 public static final string ASSERT_FAILED_MSG = 'It should Throw The Exception';
 public static final string ASSERT_NOT_FAILED_MSG = 'It should not Throw The Exception';

/***************************************************************************************************************************
@author      Ramdev Chahar
@date        25 Aug 2022
@return			void
@description  Test Method For VerifyContactPointIds Valid Record
**************************************************************************************************************************/
    @isTest
    static void testVerifyContactPointIdsValidRecord() {
        Account objAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        objAccount.PersonEmail = objAccount.Loginid__c;
        insert objAccount;
        
        ContactPointPhone objPhone = ASDAC_TestDataUtility.createContactPointPhone(false, objAccount.Id,1)[0];
        insert objPhone;
        
        List<ContactPointConsent> lstConsents = ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objPhone.Id, 1);
        String errorMessage;
        test.startTest();
        try{
            insert lstConsents;
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        test.stopTest();
        System.assertEquals(null, errorMessage, ASSERT_NOT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author      Ramdev Chahar
@date        25 Aug 2022
@return			void
@description  Test Method For VerifyContactPointIds Invalid Record Address
**************************************************************************************************************************/
    @isTest
    static void testVerifyContactPointIdsInValidRecordAddress() {
        Account objAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        objAccount.PersonEmail = objAccount.Loginid__c;
        insert objAccount;
        
        ContactPointAddress objAddress = ASDAC_TestDataUtility.createContactPointAddress(false, null,1)[0];
        insert objAddress;
        
        List<ContactPointConsent> lstConsents = ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objAddress.Id, 1);
        String errorMessage;
        test.startTest();
        try{
            insert lstConsents;
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        test.stopTest();
        System.assertNotEquals(null, errorMessage, ASSERT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author      Ramdev Chahar
@date        25 Aug 2022
@return			void
@description  Test Method For VerifyContactPointIds Invalid Record Phone
**************************************************************************************************************************/
    @isTest
    static void testVerifyContactPointIdsInValidRecordPhone() {
        Account objAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        objAccount.PersonEmail = objAccount.Loginid__c;
        insert objAccount;
        
        ContactPointPhone objPhone = ASDAC_TestDataUtility.createContactPointPhone(false, null, 1)[0];
        insert objPhone;
        
        List<ContactPointConsent> lstConsents = ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objPhone.Id, 1);
        String errorMessage;
        test.startTest();
        try{
            insert lstConsents;
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        test.stopTest();
        System.assertNotEquals(null, errorMessage, ASSERT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author      Ramdev Chahar
@date        25 Aug 2022
@return			void
@description  Test Method For VerifyContactPointIds Invalid Record Email
**************************************************************************************************************************/
    @isTest
    static void testVerifyContactPointIdsInValidRecordEmail() {
        Account objAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        objAccount.PersonEmail = objAccount.Loginid__c;
        insert objAccount;
        
        ContactPointEmail objEmail = ASDAC_TestDataUtility.createContactPointEmail(false, null, 1)[0];
        insert objEmail;
        
        List<ContactPointConsent> lstConsents = ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objEmail.Id, 1);
        String errorMessage;
        test.startTest();
        try{
            insert lstConsents;
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        test.stopTest();
        System.assertNotEquals(null, errorMessage, ASSERT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author      Ramdev Chahar
@date        25 Aug 2022
@return			void
@description  Test Method For VerifyContactPointIds Bulk Testing
**************************************************************************************************************************/
    @isTest
    static void testVerifyContactPointIdsBulkRecords() {
        Account objAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        objAccount.PersonEmail = objAccount.Loginid__c;
        insert objAccount;
        
        ContactPointAddress objAddress = ASDAC_TestDataUtility.createContactPointAddress(false, null,1)[0];
        insert objAddress;
        
        ContactPointEmail objEmail = ASDAC_TestDataUtility.createContactPointEmail(false, objAccount.Id, 1)[0];
        
        ContactPointPhone objPhone = ASDAC_TestDataUtility.createContactPointPhone(false, objAccount.Id, 1)[0];
        insert objPhone;
        
        List<ContactPointConsent> lstConsents = ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objAddress.Id, 70);
        
        lstConsents.addAll(ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objEmail.Id, 70));
        lstConsents.addAll(ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objPhone.Id, 70));
        String errorMessage;
        test.startTest();
        try{
            insert lstConsents;
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        test.stopTest();
        System.assertNotEquals(null, errorMessage, ASSERT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author      Ramdev Chahar
@date        21 spet 2022
@return			void
@description  Test Method For VerifyContactPointIds Invalid Record Address
**************************************************************************************************************************/
    @isTest
    static void testBeforeUpdateValidRecordPhone() {
        Account objAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        objAccount.PersonEmail = objAccount.Loginid__c;
        insert objAccount;
        
        ContactPointPhone objPhone = ASDAC_TestDataUtility.createContactPointPhone(false, objAccount.Id,1)[0];
        insert objPhone;
        
        List<ContactPointConsent> lstConsents = ASDAC_TestDataUtility.createContactPointConsents(false, objAccount.Id, objPhone.Id, 20);
        insert lstConsents;
        String errorMessage;
        test.startTest();
        try{
            update lstConsents;
        }catch(Exception e){
            errorMessage = e.getMessage();
        }
        test.stopTest();
        System.assertEquals(null, errorMessage, ASSERT_FAILED_MSG);
    }
}