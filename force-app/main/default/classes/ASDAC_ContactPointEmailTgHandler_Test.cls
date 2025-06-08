@isTest
public with sharing class ASDAC_ContactPointEmailTgHandler_Test {
public static final string ASSERT_NO_RECORD_DELETED_MSG = 'None of the Records should be Deleted';  
    public static final string ERROR_MESSAGE = 'Error Occured'; 
    public static final string STATUS_NOT_OPT_OUT_ERROR = 'The records with status is not opt out should not be deleted';
    public static final string ASSERT_NOT_FAILED_MSG = 'It should not Throw The Exception';
    public static final string ASSERT_FAILED_MSG = 'It should Throw The Exception';
    public static final string ASSERT_NOT_DELETED_MSG = 'The records should have been deleted';
  
/***************************************************************************************************************************
@author      Ramdev Chahar
@date         19 July 2022
@return			void
@description  Test Method For UpdateIsPrimary
**************************************************************************************************************************/
    @isTest
    static void testUpdateIsPrimary() {
        String errorMsg = '';
        List<ContactPointEmail> lstCPE = primaryAndDuplicateValidateUtility();
        test.startTest();
        try{
            Insert lstCPE;
        }catch(Exception e){
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        
        System.assertNotEquals(ERROR_MESSAGE,errorMsg, ASSERT_NOT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author      Ramdev Chahar
@date         19 July 2022
@return			void
@description  Test Method For validate Duplicate Email
**************************************************************************************************************************/
    @isTest
    static void testValidateDuplicateEmail() {
        String errorMsg = '';
        List<ContactPointEmail> lstCPE = primaryAndDuplicateValidateUtility();
        for(Integer i=0;i<50;i++) {
            lstCPE.add(lstCPE[i]);
        }
        test.startTest();
        try{
            Insert lstCPE;
        }catch(Exception e){
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        
        System.assertEquals(ERROR_MESSAGE, errorMsg, ASSERT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author      Ramdev Chahar
@date         20 July 2022
@return			void
@description  Second Test Method For validate Duplicate Email
**************************************************************************************************************************/
    @isTest
    static void testValidateDuplicateEmail2() {
        Account testAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        testAccount.PersonEmail = testAccount.Loginid__c;
        insert testAccount;
        String errorMsg = '';
        
        ContactPointEmail testCPE1 = new ContactPointEmail();
        ContactPointEmail testCPE2 = new ContactPointEmail();
        
        test.startTest();
        testCPE1.ParentId = testAccount.ID; 
        testCPE1.EmailAddress = 'test'+testAccount.Loginid__c;
        
        testCPE2.ParentId = testAccount.ID; 
        testCPE2.EmailAddress = 'test'+testAccount.Loginid__c;
        try{
            Insert testCPE1;
            Insert testCPE2;
        }Catch(Exception e){
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        
        System.assertEquals(ERROR_MESSAGE, errorMsg, ASSERT_FAILED_MSG);
    }
    
    
    /***************************************************************************************************************************
@author      Kishor Chand
@date         18/10/2022
@return			void
@description  Bulkified Test Method For deleteConsents when PrivacyConsentStatus is OptOut and ContactPointEmail is
not Primary
**************************************************************************************************************************/
    @isTest
    static void testDeleteConsentsForOptOutNonPrimaryBulkfied() {
        //get the newly created ContactPointEmail record list when isPrimry is false
        List<ContactPointEmail> lstCPE = getCPEList(ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT,false);
        
        test.startTest();
        delete lstCPE;
        test.stopTest();
        
        // query for all the newly created ContactPointConsent records to verify that they are successfully deleted.
        List<ContactPointConsent> lstConsents = [SELECT Id
                                                 FROM ContactPointConsent];                                                                     
        System.assertEquals(0, lstConsents.size(), ASSERT_NOT_DELETED_MSG);
    }
    
    /***************************************************************************************************************************
@author      Kishor Chand
@date         18/10/2022
@return			void
@description  Bulkified Test Method For deleteConsents when PrivacyConsentStatus is OptIn for few records
and ContactPointEmail is not Primary
**************************************************************************************************************************/
    @isTest
    static void testDeleteConsentsForNonPrimaryOptInStatus() {
        //get the newly created non ContactPointEmail list with status OptOut
        List<ContactPointEmail> lstCPE = getCPEList(ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT,false);
        //query few ContactPointConsent records to set the PrivacyConsentStatus as OptIn
        List<ContactPointConsent> lstConsents = [SELECT Id, PrivacyConsentStatus 
                                                 FROM ContactPointConsent LIMIT 3]; 
        
        lstConsents[0].PrivacyConsentStatus = 'OptIn';
        lstConsents[1].PrivacyConsentStatus = 'OptIn';
        lstConsents[2].PrivacyConsentStatus = 'OptIn';
        update lstConsents; 
        
        test.startTest();
        Database.delete(lstCPE,false);
        test.stopTest();
        //query all the newly created ContactPointConsent records to verify that recrods with
        //PrivacyConsentStatus OptIn are not deleted
        lstConsents = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(3, lstConsents.size(), STATUS_NOT_OPT_OUT_ERROR);
    }
    
    /***************************************************************************************************************************
@author      Kishor Chand
@date         18/10/2022
@return			void
@description  Bulkified Test Method For deleteConsents when ContactPointEmail is Primary
and ContactPointEmail is not Primary
**************************************************************************************************************************/
    @isTest
    static void testDeleteConsentsPrimary() {
        //to check for the exception when deleting Primary ContactPointEmail
        Boolean isException = false;
        //get the newly created Primary ContactPointEmail records with PrivacyConsentStatus OptOut
        List<ContactPointEmail> lstCPE = getCPEList(ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT,true);
        
        test.startTest();
        try{
            delete lstCPE;
        } catch (Exception ex) {
            isException = true;
        }
        test.stopTest();
        
        //assert that the exception is thrown
        System.assert(isException, ASSERT_FAILED_MSG);
        
        //query all the newly created ContactPointConsent to verify that none of 
        //them are deleted as they are linked to Primary ContactPointEmail records
        List<ContactPointConsent> lstConsents = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(20, lstConsents.size(),ASSERT_NO_RECORD_DELETED_MSG);
    }
    
    /****************************************************************************************************************************************
@author      Kishor Chand
@date         28/10/2022
@param:        String privacyConsentStatus - to set the PrivacyConsentStatus of ContactPointConsent
to OptOut or OptIn
Boolean isPrimary - to set the ContactPointEmail as Primary  or not
@return:       List<ContactPointEmail> - to test for deletion of ContactPointEmail records and related
ContactPointConsent records
@description  helper method to insert and get ContactPointEmail and related records
******************************************************************************************************************************************/            
    static List<ContactPointEmail> getCPEList(String privacyConsentStatus, Boolean isPrimary) {
        //get the newly created accout object list
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(20, false);
        insert lstAccount;
        //stores the newly created ContactPointEmail objects and used to insert the records
        List<ContactPointEmail> lstCPE = new List<ContactPointEmail>();
        for(Integer i = 0; i < 20; i++){
            //get the newly creted ContactPointEmail ojbect created against each account records
            ContactPointEmail objCPE = ASDAC_TestDataUtility.createContactPointEmail(false,lstAccount[i].Id,1).get(0);
            //make the ContactPointEmail as primary and the EmailAddress same as related Account loginId
            if(isPrimary) {
                objCPE.isPrimary = true;
                objCPE.EmailAddress = lstAccount[i].LoginId__c;
            }
            lstCPE.add(objCPE);  
        }
        insert lstCPE;
        
        //stores the newly created ContactPointConsent objects and used to insert the records
        List<ContactPointConsent> lstCPC = new List<ContactPointConsent>();
        for(Integer i = 0; i < 20; i++){
            //get the newly creted ContactPointConsent ojbect created against each account and account related ContactPointEmail
            ContactPointConsent objCPC = ASDAC_TestDataUtility.createContactPointConsents(false,lstAccount[i].Id,lstCPE[i].Id,1).get(0);
            //set PrivacyConsentStatus to either OptIn or OptOut according to the test scenarios
            if(String.isNotBlank(privacyConsentStatus)) {
                objCPC.PrivacyConsentStatus = privacyConsentStatus;
            }
            lstCPC.add(objCPC);  
        }
        insert lstCPC;
        return lstCPE;
    }
    /****************************************************************************************************************************************
@author      Kishor Chand
@date         15/11/2022
@return:       List<ContactPointEmail> - to test for insertion of ContactPointEmail records
@description  helper method to  get ContactPointEmail and related records
******************************************************************************************************************************************/
    static List<ContactPointEmail> primaryAndDuplicateValidateUtility() {
        //store and insert Account records
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(100, false);
        insert lstAccount;
        List<ContactPointEmail> lstCPE = new List<ContactPointEmail>();
        //create two ContactPointEmail against each Account
        for(Integer i=0;i<100;i++){
            //create unique primary ContactPointEmail for each Account
            ContactPointEmail objCPE = ASDAC_TestDataUtility.createContactPointEmail(false,lstAccount[i].Id,1)[0];
            objCPE.EmailAddress = 'test'+lstAccount[i].Loginid__c;
            lstCPE.add(objCPE);
            //create non primary ContactPointEmail for each Account
            objCPE = ASDAC_TestDataUtility.createContactPointEmail(false,lstAccount[i].Id,1)[0];
            objCPE.EmailAddress = lstAccount[i].Loginid__c;
            objCPE.IsPrimary = false;
            lstCPE.add(objCPE);
        }
        return lstCPE;
    }
}