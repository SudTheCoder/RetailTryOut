public with sharing class ASDAC_AccountTriggerHandler  extends ASDAC_TriggerFramworkService {
    public static final string CPE_HANDLER = 'ASDAC_ContactPointEmailTriggerHandler';
    private Map<Id, Account> oldAccMap;
    private List<Account> lstNewAcc;
    
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is constructor of the class.
**********************************************************************************************/    
    public ASDAC_AccountTriggerHandler() {
        this.oldAccMap = (Map<Id, Account>) Trigger.oldMap;
        this.lstNewAcc = (List<Account>) Trigger.new;
    }
    /**********************************************************************************************
    @author        Sapient: Sanjeev Shukla
    @date          14 June 2023
    @return        void
    @description   This method overrides afterUpdate Trigger
    **********************************************************************************************/    
    public override void afterUpdate() {
        try {    
            updatePrimaryContactPointEmail(lstNewAcc, oldAccMap);
        }catch(Exception ex) {
                        ASDAC_Logger.logException(ex);
        }
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides beforeDelete Trigger
**********************************************************************************************/    
    public override void beforeDelete() {
        //delete the contact point consent related to account
        ASDAC_CommonUtility.deleteConsents(oldAccMap,ASDAC_GlobalConstants.OBJACCOUNT); 
    }
    
    
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
            ASDAC_TriggerFramworkService.bypass(CPE_HANDLER);
            update lstCPE;
            ASDAC_TriggerFramworkService.clearBypass(CPE_HANDLER);
        }

    }
}