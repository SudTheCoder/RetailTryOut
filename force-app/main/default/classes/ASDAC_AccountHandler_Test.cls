/***************************************************************************************************************************
@author       Ramdev Chahar
@date         25 Aug 2022
@description  Test Class For ASDAC_AccountHandler Class
**************************************************************************************************************************/
@IsTest
public with sharing class ASDAC_AccountHandler_Test {
    public static final string ASSERT_NOT_DELETED_MSG = 'All Records Should be Deleted';
    public static final string ASSERT_EMAIL_NOT_UPDATED_MSG = 'Email Address Not updated';
    public static final string PHONE_HANDLER = 'ASDAC_ContactPointPhoneHandler';
    public static final string EMAIL_HANDLER = 'ASDAC_ContactPointEmailHandler';
    public static final string ADDRESS_HANDLER = 'ASDAC_ContactPointAddressHandler';
    public static final string CONSENT_HANDLER = 'ASDAC_ContactPointConsentHandler';
    public static final string ACCOUNT_HANDLER = 'ASDAC_AccountHandler';
    /***************************************************************************************************************************
@author       Kishor Chand
@date         15 Nov 2022
@return 		void
@description  Test Method For before delete when ContactPointConsent is related to ContactPointPhone
**************************************************************************************************************************/
    @isTest
    static void testBeforeDeleteForContactPointPhone() {
        
        //to store newly created account records and create its related records too
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, 'ASDA Base')[0];
        ocsCollBPO.userName = ocsCollBPO.userName + 'test1234';
        ocsCollBPO.FederationIdentifier = ocsCollBPO.FederationIdentifier + 'test1234';
        insert ocsCollBPO;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsCollBPO},ASDAC_GlobalConstants.STRING_OCS_COLLEAGUE_PERMISSION_SET_GROUP_NAME);
        System.runAs(ocsCollBPO) {
            List<Account> lstAccount = getAccounts(ASDAC_GlobalConstants.OBJCONTACTPOINTPHONE);
            Delete lstAccount;
        } 
        test.stopTest();
        
        //query to retrive all newly created contact point consent against contact point phone 
        //to verify that all related consents are successfully deleted
        List<ContactPointConsent> lstCPC = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(0, lstCPC.size(), ASSERT_NOT_DELETED_MSG);
    }
    /***************************************************************************************************************************
@author       Ramdev Chahar
@date         25 Aug 2022
@return 		void
@description  Test Method For before delete when ContactPointConsent is related to ContactPointEmail
**************************************************************************************************************************/
    @isTest
    static void testBeforeDeleteForContactPointEmail() {
        
        //to store newly created account records and create its related records too
        List<Account> lstAccount = getAccounts(ASDAC_GlobalConstants.OBJCONTACTPOINTEMAIL);
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        Delete lstAccount;
        test.stopTest();
        
        //query to retrive all newly created contact point consent against contact point email
        //to verify that all related consents are successfully deleted
        List<ContactPointConsent> lstCPC = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(0, lstCPC.size(), ASSERT_NOT_DELETED_MSG);
    }
    /***************************************************************************************************************************
@author       Ramdev Chahar
@date         25 Aug 2022
@return 		void
@description  Test Method For before delete when ContactPointConsent is related to ContactPointAddress
**************************************************************************************************************************/
    @isTest
    static void testBeforeDeleteForContactPointAddress() {
        
        //to store newly created account records and create its related records too
        List<Account> lstAccount = getAccounts(ASDAC_GlobalConstants.OBJCONTACTPOINTADDRESS);
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        Delete lstAccount;
        test.stopTest();
        
        //query to retrive all newly created contact point consent against contact point address
        //to verify that all related consents are successfully deleted
        List<ContactPointConsent> lstCPC = [SELECT Id FROM ContactPointConsent];
        System.assertEquals(0, lstCPC.size(), ASSERT_NOT_DELETED_MSG);
    }
    /****************************************************************************************************************************************
@author       Ramdev Chahar
@date         20 June 2023
@return 		void
@description  test method for updatePrimaryContactPointEmail
******************************************************************************************************************************************/
    @isTest
    static void testUpdatePrimaryContactPointEmail() {
        
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(20,false);
        List<ContactPointEmail> lstCPE = new List<ContactPointEmail>();
        
        ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER); 
        Insert lstAccount;
        ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER); 
        
        for(Account objAccount: lstAccount){
            lstCPE.add(new ContactPointEmail(EmailAddress = objAccount.LoginId__c, IsPrimary = true, ParentId = objAccount.Id));
            objAccount.Source__c = ASDAC_GlobalConstants.STRING_CONTACT_CENTRE;
            objAccount.AccountRegistrationStatus__c = ASDAC_GlobalConstants.STRING_MANUAL;
            objAccount.Loginid__c = 'new' + objAccount.Loginid__c;
            objAccount.PersonEmail = objAccount.Loginid__c;
        }
        ASDAC_TriggerHandler.bypass(EMAIL_HANDLER);
        Insert lstCPE;
        ASDAC_TriggerHandler.clearBypass(EMAIL_HANDLER);
        
        test.startTest();
        ASDAC_TriggerHandlerObj.enableOldTriggerFramework = true;
        update lstAccount;
        test.stopTest();
        //Check any random email if it is updated or not
        Integer randomIndex = Integer.valueof((Math.random() * 19));
        ContactPointEmail cpe = [SELECT EmailAddress FROM ContactPointEmail WHERE Id =:lstCPE[randomIndex].Id];
        System.assertEquals('new'+lstCPE[randomIndex].EmailAddress, cpe.EmailAddress, ASSERT_EMAIL_NOT_UPDATED_MSG);
    }
    
    /****************************************************************************************************************************************
@author       Kishor Chand
@date         15/11/2022
@param        String objContactName- to check whether Parent of ContactPointConsent is ContactPointEmail,
ContactPointPhone or ContactPointAddress
@return       List<Account> - to test for deletion of Account records and related
ContactPointConsent records
@description  helper method to get Account and related records
******************************************************************************************************************************************/      
    static List<Account> getAccounts(String objContactName) {
        //get the list of newly created accounts
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(20, false);
        insert lstAccount;
        //to sotre all the newly ContactPointPhone,Email or Address object against accounts
        List<SObject> lstSObject = new List<SObject>();
        for(Account objAccount : lstAccount) {
            if(objContactName == ASDAC_GlobalConstants.OBJCONTACTPOINTPHONE) {
                lstSObject.add(ASDAC_TestDataUtility.createContactPointPhone(false, objAccount.Id, 1)[0]);
                ASDAC_TriggerHandler.bypass(PHONE_HANDLER);
            } else if(objContactName == ASDAC_GlobalConstants.OBJCONTACTPOINTEMAIL) { 
                lstSObject.add(ASDAC_TestDataUtility.createContactPointEmail(false, objAccount.Id, 1)[0]); 
                ASDAC_TriggerHandler.bypass(EMAIL_HANDLER);   
            } else {
                lstSObject.add(ASDAC_TestDataUtility.createContactPointAddress(false, objAccount.Id, 1)[0]);
                ASDAC_TriggerHandler.bypass(ADDRESS_HANDLER);   
            }
        }
        Insert lstSObject;
        //create ContactPointConsent against each account and related ContactPoint Phone,Email or Address
        getConsents(lstAccount, lstSObject);    
        return lstAccount;     
    }
    /****************************************************************************************************************************************
@author       Kishor Chand
@date         15/11/2022
@param        List<Account> lstAccount - to create ContactPointConsent against each account record
List<SObject> - to create ContactPointConsent against ContactPointPhone,
ContactPointEmail and ContactPointAddress
@return 		void
@description  helper method to get ContactPointConsent against each Account
******************************************************************************************************************************************/
    static void getConsents(List<Account> lstAccount, List<SObject> lstSObect) {
        List<ContactPointConsent> lstCPC = new List<ContactPointConsent>();
        for(Integer i=0;i<20;i++) {
            lstCPC.add(ASDAC_TestDataUtility.createContactPointConsents(false,lstAccount[i].Id,String.valueOf(lstSObect[i].get('Id')),1).get(0));
        }
        ASDAC_TriggerHandler.bypass(CONSENT_HANDLER);
        Insert lstCPC;
    }
}