public with sharing class ASDAC_AccountHandler  extends ASDAC_TriggerHandlerBase {
 /**********************************************************************************************
    @author        Sapient: Dependra Singh
    @date          11 May 2022
    @param         ASDAC_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger

    **********************************************************************************************/
	
    public static final string CPE_HANDLER = 'ASDAC_ContactPointEmailHandler';
	
    public override void mainEntry(ASDAC_TriggerHandlerObj inputParam) {
        try {
           
            if (inputParam.isUpdate && inputParam.isAfter) {
                updatePrimaryContactPointEmail((List<Account>)inputParam.newlist, (Map<Id, Account>)inputParam.oldMap);
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                //delete the contact point consent related to account
                ASDAC_CommonUtility.deleteConsents((Map<Id, Account>)inputParam.oldMap, ASDAC_GlobalConstants.OBJACCOUNT); 
            }
			
        } catch (Exception ex) {
            ASDAC_Logger.logException(ex);

        } finally {
            //Reset the active function to null in case this class was first in stack
            //this indicates that the trigger has finished firing so it no longer needs to control flow
            ASDAC_TriggerCentralDispatcher.activeFunction = null;
            ASDAC_Logger.writeLogsToDatabase();
        }
    }
    /**********************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          12 Jan 2023
    @param         Account List
    @return        void
    @description   This method is to primary contactpointemail's email if the LoginId of manual account is updated
    **********************************************************************************************/
    private void updatePrimaryContactPointEmail(List<Account> newList, Map<Id, Account> oldMap){
        Map<Id, String> mapAccountIdToEmail = new Map<Id, String>();
        for(Account objAccount :newList){
            if(objAccount.Loginid__c != oldMap.get(objAccount.Id).Loginid__c && objAccount.Source__c == ASDAC_GlobalConstants.STRING_CONTACT_CENTRE && objAccount.AccountRegistrationStatus__c == ASDAC_GlobalConstants.STRING_MANUAL){
                mapAccountIdToEmail.put(objAccount.Id, objAccount.Loginid__c);
            }
        }
        
        List<ContactPointEmail> lstCPE = [SELECT Id, EmailAddress, ParentId 
                                          FROM ContactPointEmail 
                                          WHERE ParentId IN :mapAccountIdToEmail.keySet() AND IsPrimary = true ];
        
        for(ContactPointEmail objCPE :lstCPE){
            objCPE.EmailAddress = mapAccountIdToEmail.get(objCPE.ParentId);
        }
        if(lstCPE.size()>0 && (Schema.sObjectType.ContactPointEmail.fields.EmailAddress.isUpdateable())){
            ASDAC_TriggerHandler.bypass(CPE_HANDLER);
            update lstCPE;
            ASDAC_TriggerHandler.clearBypass(CPE_HANDLER);
        }

    }
}