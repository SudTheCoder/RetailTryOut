@isTest
public with sharing class ASDAC_ContactPointPhoneTgHandler_Test {
public static final string ASSERT_NOT_DELETED_MSG = 'None of the Records should be Deleted';
    public static final string STATUS_NOT_OPT_OUT_ERROR = 'The records with status is not opt out should not be deleted';
    public static final string ASSERT_DELETED_MSG = 'All of the Records should be Deleted';
    public static final String ERROR_MESSAGE = 'Error Occured';
    public static final String ASSERT_NOT_FAILED_MSG = 'It should not Throw The Exception';
    public static final String ASSERT_FAILED_MSG = 'It should Throw The Exception';
    public static final String ASSERT_SOULD_BE_BLANK_MSG = 'It should be blank';
    public static final string ACCOUNT_HANDLER = 'ASDAC_AccountHandler';
    public static final string CPP_HANDLER = 'ASDAC_ContactPointPhoneHandler';
     
/***************************************************************************************************************************
@author       Ramdev Chahar
@date         19 July 2022
@return 		void
@description  Test Method For UpdateIsPrimary
**************************************************************************************************************************/
    @isTest
    static void testUpdateIsPrimary() {
        //create account records and store them in Account List - lstAccount
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(100, false);
        ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER);
        insert lstAccount;
        ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER);
        //to store newly created ContactPointPhone object
        ContactPointPhone objCPP;
        //set the errorMsg as blank to test verify that no error has occured
        String errorMsg = '';
        //to store newly created ContactPointPhone records
        List<ContactPointPhone> lstCPP = new List<ContactPointPhone>();
        for(Integer i=0;i<100;i++){
            //create one primary and one non primary ContactPointPhone against each account
            lstCPP.add(ASDAC_TestDataUtility.createContactPointPhone(false,lstAccount[i].Id,1)[0]);
            objCPP = ASDAC_TestDataUtility.createContactPointPhone(false,lstAccount[i].Id,1)[0];
            objCPP.IsPrimary = false;
            lstCPP.add(objCPP);
        }
        Insert lstCPP;
        test.startTest();
        
        List<ContactPointPhone> lstCPPToUpdate = new List<ContactPointPhone>();
        try{
            for(Integer i=0;i<20;i++){
                //change non primary to primay
                if(math.mod(i,2)!=0){
                    lstCPP[i].IsPrimary = true;
                    lstCPPToUpdate.add(lstCPP[i]);
                }
            }
            Update lstCPPToUpdate;
        }catch(Exception e){
            System.debug(e.getMessage());
            errorMsg = ERROR_MESSAGE;
        }
        test.stopTest();
        //assert that no erro has occured which updating
        System.assertNotEquals(ERROR_MESSAGE, errorMsg, ASSERT_NOT_FAILED_MSG);
    }
    /****************************************************************************************************************************************
@author       Kishor Chand
@date         28/10/2022
@return 		void
@description  Bulkified Test Method For deleteConsents when PrivacyConsentStatus is OptOut and Contact Point Address is not default
******************************************************************************************************************************************/
    @isTest
    static void testDeleteConsentsForOptOut() {
        //get the newly created ContactPointPhone records
        List<ContactPointPhone> lstCPP = getCPPList(ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT);
        
        test.startTest();
        delete lstCPP;
        test.stopTest();
        //query all newly created ContactPointConsent to verify all of them are deleted successfully
        List<ContactPointConsent> lstConsents = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(0, lstConsents.size(), ASSERT_DELETED_MSG);
    }
    
    /****************************************************************************************************************************************
@author       Kishor Chand
@date         28/10/2022
@return 		void
@description  Bulkified Test Method For deleteConsents when PrivacyConsentStatus is OptIn for few records
******************************************************************************************************************************************/
    @isTest
    static void testDeleteConsentsForOptInConsentStatus() {
        //get newly created ContactPointPhone records
        List<ContactPointPhone> lstCPP = getCPPList(ASDAC_GlobalConstants.PRIVACY_CONSENT_STATUS_OPTOUT);
        
        //query to get few ContactPointConsent records to set PrivacyConsentStatus as OptIn
        List<ContactPointConsent> lstConsents = [SELECT Id, PrivacyConsentStatus 
                                                 FROM ContactPointConsent LIMIT 3]; 
        
        lstConsents[0].PrivacyConsentStatus = 'NotSeen';
        lstConsents[1].PrivacyConsentStatus = 'Seen';
        lstConsents[2].PrivacyConsentStatus = 'OptIn';
        
        update lstConsents; 
        
        test.startTest();
        Database.delete(lstCPP,false);
        test.stopTest();
        
        //query to verify ContactPointConsent records whose PrivacyConsentStatus is OptIn are not deleted
        lstConsents = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(3, lstConsents.size(), ASSERT_NOT_DELETED_MSG);
    }
    
    /****************************************************************************************************************************************
@author       Ramdev Chahar
@date         20 June 2023
@return 		void
@description  test method for blankPhoneOnPrimaryDelete
******************************************************************************************************************************************/
    @isTest
    static void testBlankPhoneOnPrimaryDelete() {
        //get newly created ContactPointPhone records
        List<ContactPointPhone> lstCPP = getCPPList(null);
        
        test.startTest();
        Delete lstCPP;
        test.stopTest();
        
        Integer randomIndex = Integer.valueof((Math.random() * 19));
        Account objAccount = [SELECT Id, Phone FROM Account WHERE Id =:lstCPP[randomIndex].ParentId][0];
        System.assertEquals(null,objAccount.Phone,ASSERT_SOULD_BE_BLANK_MSG );
        
    }
    
    /****************************************************************************************************************************************
@author       Kishor Chand
@date         28/10/2022
@param:        String privacyConsentStatus - to set the PrivacyConsentStatus of ContactPointConsent
to OptOut or OptIn
@return:       List<ContactPointPhone> - to test for deletion of ContactPointPhone records and related
ContactPointConsent records
@description  helper method to get Contact Point Phones and related records
******************************************************************************************************************************************/      
    static List<ContactPointPhone> getCPPList(String privacyConsentStatus) {
        //get newly created Account object list
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(20, false);
        
        ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER);
        insert lstAccount;
        ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER);
        
        //stores the newly created ContactPointPhone objects and used to insert the records
        List<ContactPointPhone> lstCPP = new List<ContactPointPhone>();
        for(Integer i = 0; i < 20; i++){
            //get the newly creted ContactPointPhone ojbect created against each account records
            ContactPointPhone objCPP = ASDAC_TestDataUtility.createContactPointPhone(false,lstAccount[i].Id,1).get(0);
            lstCPP.add(objCPP);  
        }
        ASDAC_TriggerHandler.bypass(CPP_HANDLER);
        insert lstCPP;
        ASDAC_TriggerHandler.clearBypass(CPP_HANDLER);
        //stores the newly created ContactPointConsent objects and used to insert the records
        if(String.isNotBlank(privacyConsentStatus)){
            List<ContactPointConsent> lstCPC = new List<ContactPointConsent>();
            for(Integer i = 0; i < 20; i++){
                //get the newly creted ContactPointConsent ojbect created against each account and account related ContactPointPhone
                ContactPointConsent objCPC = ASDAC_TestDataUtility.createContactPointConsents(false,lstAccount[i].Id,lstCPP[i].Id,1).get(0);
                //set PrivacyConsentStatus to either OptIn or OptOut according to the test scenarios
                if(String.isNotBlank(privacyConsentStatus)) {
                    objCPC.PrivacyConsentStatus = privacyConsentStatus;
                }
                lstCPC.add(objCPC);  
            }
            insert lstCPC;
        }
        return lstCPP;
    } 
}