/***************************************************************************************************************************
@author       Ramdev Chahar
@date         27/06/2022
@description  Test Class For ASDAC_ContactPointAddressHandler Class
**************************************************************************************************************************/

@IsTest
public with sharing class ASDAC_ContactPointAddressHandler_Test {
    public static final string ASSERT_NOT_DELETED_MSG = 'None of the Records should be Deleted';
    public static final string STATUS_NOT_OPT_OUT_ERROR = 'The records with status is not opt out should not be deleted';
    public static final string ASSERT_DELETED_MSG = 'All of the Records should be Deleted';
    public static final String ERROR_MESSAGE = 'Error Occured';
    public static final String ASSERT_NOT_FAILED_MSG = 'It should not Throw The Exception';
    public static final String ASSERT_FAILED_MSG = 'It should Throw The Exception';
    public static final String FAULTYADDRESSTYPE = 'FaultyAddressType';
    public static final String FAULTYUSAGETYPE = 'FaultyUsageType';
    public static final String ASSERT_SOULD_BE_BLANK_MSG = 'It should be blank';
    public static final string CPA_HANDLER = 'ASDAC_ContactPointAddressHandler';
    private static final string ACCOUNT_HANDLER = 'ASDAC_AccountHandler';

/***************************************************************************************************************************
@author       Ramdev Chahar
@date         27/06/2022
@return			void
@description  Test Method For BeforeInsert
**************************************************************************************************************************/
    @isTest
    static void testBeforeInsert() {
        Account testAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        insert testAccount;
        ContactPointAddress testCPA = ASDAC_TestDataUtility.createContactPointAddress(false,testAccount.Id,1).get(0);
        String errorMsg = ''; 
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        testCPA.AddressType = FAULTYADDRESSTYPE;
        testCPA.UsageType = FAULTYUSAGETYPE;
        try {
            insert testCPA;
        } catch (Exception e) {
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        
        System.assertEquals(errorMsg, ERROR_MESSAGE, ASSERT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author       Ramdev Chahar
@date         27/06/2022
@return			void
@description  Bulk Test Method For BeforeInsert
**************************************************************************************************************************/
    @isTest
    static void testBeforeInsertBulkRecord() {
        Account testAccount = ASDAC_TestDataUtility.createPersonAccount(true);
        List<ContactPointAddress> cpaList = new List<ContactPointAddress>();
        String errorMsg = '';
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        for (Integer i = 0; i < 150; i++) {
            cpaList.add(
                new ContactPointAddress(
                    ParentId = testAccount.Id,
                    AddressType = FAULTYADDRESSTYPE,
                    UsageType = FAULTYUSAGETYPE
                )
            );
        }
        try {
            insert cpaList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        
        System.assertEquals(errorMsg, ERROR_MESSAGE, ASSERT_FAILED_MSG);
    }
    /***************************************************************************************************************************
@author       Ramdev Chahar
@date         27/06/2022
@return			void
@description  Test Method For BeforeUpdate
**************************************************************************************************************************/
    @isTest
    static void testBeforeUpdate() {
        Account testAccount = ASDAC_TestDataUtility.createPersonAccount(false);
        insert testAccount;
        ContactPointAddress testCPA = ASDAC_TestDataUtility.createContactPointAddress(
            false,
            testAccount.Id,
            1
        ).get(0);
        insert testCPA;
        String errorMsg = '';
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        testCPA.AddressType = FAULTYADDRESSTYPE;
        testCPA.UsageType = FAULTYUSAGETYPE;
        try {
            update testCPA;
        } catch (Exception e) {
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        
        System.assertEquals(ERROR_MESSAGE, errorMsg, ASSERT_FAILED_MSG);
    }
    
    /***************************************************************************************************************************
@author       Ramdev Chahar
@date         27/06/2022
@return			void
@description  Bulk Test Method For BeforeUpdate
**************************************************************************************************************************/
    @isTest
    static void testBeforeUpdateBulkRecord() {
        Account testAccount = ASDAC_TestDataUtility.createPersonAccounts(1,true).get(0);
        List<ContactPointAddress> cpaList = new List<ContactPointAddress>();
        String errorMsg = '';
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        for (Integer i = 0; i < 150; i++) {
            cpaList.add(
                new ContactPointAddress(ParentId = testAccount.Id, Name = 'Test ' + i)
            );
        }
        insert cpaList;
        
        try {
            for (ContactPointAddress cpa : cpaList) {
                cpa.AddressType = FAULTYADDRESSTYPE;
                cpa.UsageType = FAULTYUSAGETYPE;
            }
            update cpaList;
        } catch (Exception e) {
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        
        System.assertEquals(errorMsg, ERROR_MESSAGE, ASSERT_FAILED_MSG);
    }
    /****************************************************************************************************************************************
@author       Kishor Chand
@date         28/10/2022
@return			void
@description  Bulkified Test Method For deleteConsents when c is OptOut and Contact Point Address is not default
******************************************************************************************************************************************/ 
    @isTest
    static void testDeleteConsentsForOptOutNotDefault() {
        //get the List of newly created ContactPointAddress
        List<ContactPointAddress> lstCPA = getCPAList(ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT,false);
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        delete lstCPA;
        test.stopTest();
        
        //Query all newly created with consent to verify all of them are deleted successfully 
        //when their PrivacyConsentStatus is OptOut
        List<ContactPointConsent> lstConsents = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(0, lstConsents.size(), ASSERT_DELETED_MSG);
    }
    /****************************************************************************************************************************************
@author       Kishor Chand
@date         28/10/2022
@return			void
@description  Bulkified Test Method For deleteConsents when few records have PrivacyConsentStatus is optin
*               then those records should not be deleted
******************************************************************************************************************************************/
    
    @isTest
    static void testDeleteConsentsForOptInStatus() {
        //get the newly created ContactPointAddressList where none of them are default
        List<ContactPointAddress> lstCPA = getCPAList(ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT,false);
        //query few newly insertd ContactPointConsent to change their PrivacyConsentStatus to OptIn
        List<ContactPointConsent> lstConsents = [SELECT Id, PrivacyConsentStatus 
                                                 FROM ContactPointConsent LIMIT 3]; 
        
        lstConsents[0].PrivacyConsentStatus = 'OptIn';
        lstConsents[1].PrivacyConsentStatus = 'OptIn';
        lstConsents[2].PrivacyConsentStatus = 'OptIn';
        update lstConsents; 
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        Database.delete(lstCPA,false);
        test.stopTest();
        
        //query all newly created ContactPointConsent to verify that only PrivacyConsentStatus OptIn
        //ContactPointConsent are not deleted
        lstConsents = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(3, lstConsents.size(), ASSERT_NOT_DELETED_MSG);
    }
    /****************************************************************************************************************************************
@author       Ramdev Chahar
@date         20 June 2022
@return			void
@description  test method for blankAddressFieldsOnDefaultDelete
******************************************************************************************************************************************/
    @isTest
    static void testBlankAddressFieldsOnDefaultDelete() {
        //get newly created ContactPointPhone records
        List<ContactPointAddress> lstCPA = getCPAList(null, true);
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        Delete lstCPA;
        test.stopTest();
        
        Integer randomIndex = Integer.valueof((Math.random() * 19));
        Account objAccount = [SELECT Id, AddressLine1__pc FROM Account WHERE Id =:lstCPA[randomIndex].ParentId][0];
        System.assertEquals(null,objAccount.AddressLine1__pc,ASSERT_SOULD_BE_BLANK_MSG );
        
    }
    /****************************************************************************************************************************************
@author       Ramdev Chahar
@date         27 Feb 2023
@return			void
@description  test method for updateDefaultAddress
******************************************************************************************************************************************/
    @isTest
    static void testUpdateDefaultAddress() {
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(100,false);
        ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER);
        insert lstAccount;
        ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER);
        List<ContactPointAddress> lstCPA1 = new List<ContactPointAddress>();
        List<ContactPointAddress> lstCPA2 = new List<ContactPointAddress>();
        List<ContactPointAddress> lstCPA;
        for(Account objAccount: lstAccount){
            lstCPA = ASDAC_TestDataUtility.createContactPointAddress(false,objAccount.Id,2);
            lstCPA[0].isDefault = true;
            lstCPA[1].isDefault = true;
            lstCPA1.add(lstCPA[0]);
            lstCPA2.add(lstCPA[1]);
        }
        ASDAC_TriggerHandler.bypass(CPA_HANDLER);
        insert lstCPA1;
        ASDAC_TriggerHandler.clearBypass(CPA_HANDLER);
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        insert lstCPA2;
        test.stopTest();
        ContactPointAddress objCPA = [SELECT Id, isDefault FROM ContactPointAddress WHERE Id in :lstCPA1 WITH SECURITY_ENFORCED][0];
        System.assertEquals(false, objCPA.IsDefault, ERROR_MESSAGE);
        
    }
    /****************************************************************************************************************************************
@author       Kishor Chand
@date        28/10/2022
@param        String privacyConsentStatus - to set the PrivacyConsentStatus of ContactPointConsent
to OptOut or OptIn
Boolean isDefault - to set the ContactPointAddress as default or not
@return       List<ContactPointAddress> - to test for deletion of ContactPointAddress records and related
ContactPointConsent records
@description  helper method to insert and get Contact Point Address and related records
******************************************************************************************************************************************/ 
    
    static List<ContactPointAddress> getCPAList(String privacyConsentStatus, Boolean isDefault) {
        //creating new account records
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(20, false);
        insert lstAccount;
        
        //creating new ContactPointAddress records
        List<ContactPointAddress> lstCPA = new List<ContactPointAddress>();
        for(Integer i = 0; i < 20; i++){
            ContactPointAddress objCPA = ASDAC_TestDataUtility.createContactPointAddress(false,lstAccount[i].Id,1).get(0);
            // to make the ContactPointAddress as default check the isDefault 
            //set it accordingly
            if(isDefault) {
                objCPA.isDefault = true;
            }
            lstCPA.add(objCPA);  
        }
        ASDAC_TriggerHandler.bypass(CPA_HANDLER);
        insert lstCPA;
        ASDAC_TriggerHandler.clearBypass(CPA_HANDLER);
        
        //stores ContactPointConsent object
        if(String.isNotBlank(privacyConsentStatus)){
            List<ContactPointConsent> lstCPC = new List<ContactPointConsent>();
            for(Integer i = 0; i < 20; i++){
                //creating ContactPointConsent ojbect and Updating its PrivacyConsentStatus accordingly
                //creating one object for the same at a time.
                ContactPointConsent objCPC = ASDAC_TestDataUtility.createContactPointConsents(false,lstAccount[i].Id,lstCPA[i].Id,1).get(0);
                if(String.isNotBlank(privacyConsentStatus)) {
                    objCPC.PrivacyConsentStatus = privacyConsentStatus;
                }
                lstCPC.add(objCPC);  
            }
            insert lstCPC;
        }
        return lstCPA;
    } 
}