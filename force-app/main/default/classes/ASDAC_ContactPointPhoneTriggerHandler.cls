public with sharing class ASDAC_ContactPointPhoneTriggerHandler extends ASDAC_TriggerFramworkService {
/* *********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is ContactPointPhone Object Trigger Handler Class contains business logic.
********************************************************************************************* */
    private Map<Id, ContactPointPhone> oldCPPMap;
    private List<ContactPointPhone> lstCPP;
    private List<ContactPointPhone> lstOldCPP;
    private static final string ACCOUNT_HANDLER = 'ASDAC_AccountTriggerHandler';
    private static final string PHONE_HANDLER = 'ASDAC_ContactPointPhoneTriggerHandler';
    /**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is constructor of the class.
**********************************************************************************************/
    public ASDAC_ContactPointPhoneTriggerHandler() {
        this.oldCPPMap = (Map<Id,ContactPointPhone>) Trigger.oldMap;
        this.lstCPP = (List<ContactPointPhone>) Trigger.new;
        this.lstOldCPP = (List<ContactPointPhone>) Trigger.old;
    }

/********************************************************************************************** 
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides afterInsert Trigger
**********************************************************************************************/
    public override void afterInsert() {
        try{
            updateIsPrimary(lstCPP, null);    
        }catch(Exception ex){
            ASDAC_Logger.logException(ex);
        }
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides afterUpdate Trigger
**********************************************************************************************/
    public override void afterUpdate() {
        try{
            updateIsPrimary(lstCPP, oldCPPMap);    
        }catch(Exception ex){
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
        ASDAC_CommonUtility.deleteConsents(oldCPPMap,ASDAC_GlobalConstants.OBJCONTACTPOINTPHONE);
    }

/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides beforeDelete Trigger
**********************************************************************************************/
    public override void afterDelete() {
        try{
            blankPhoneOnPrimaryDelete(lstOldCPP);    
        }catch(Exception ex){
            ASDAC_Logger.logException(ex);
        }
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         ContactPointPhone List, ContactPointPhone Map
@return        void
@description   This method is to update is primary field on ContactPointPhone and accordingly
reflect the primary Phone number on the parent account Phone field.
**********************************************************************************************/
    private void updateIsPrimary(List<ContactPointPhone> newList,Map<Id, ContactPointPhone> oldMap ){
        Map<Id, String> mapAccountIdToPhone = new Map<Id, String>();
        for(ContactPointPhone cpp : newList){
            if(cpp.IsPrimary == true && (oldMap == null || oldMap.get(cpp.Id).IsPrimary == false || (oldMap.get(cpp.Id).IsPrimary == true && oldMap.get(cpp.Id).TelephoneNumber != cpp.TelephoneNumber))){
                mapAccountIdToPhone.put(cpp.ParentId, cpp.TelephoneNumber);
            }
        }
        
        List<ContactPointPhone> lstCPP = [SELECT Id, IsPrimary, ParentId, TelephoneNumber 
                                          FROM ContactPointPhone
                                          WHERE ParentId IN :mapAccountIdToPhone.keySet() AND IsPrimary = true AND Id not in :newList
                                          WITH SECURITY_ENFORCED];
        
        
        for(ContactPointPhone objCPP: lstCPP){
            objCPP.IsPrimary = false;
            objCPP.UpdatedDatetime__c = System.now();
        }
        List<Account> lstAccountToUpdate = new List<Account>();
        for(Id objId :mapAccountIdToPhone.keyset()){
            lstAccountToUpdate.add(new Account(Id = objId, Phone = mapAccountIdToPhone.get(objId)));
        }
        //update the accounts if and only if there is change in Phone number
        if(lstAccountToUpdate.size()>0 && (Schema.sObjectType.Account.fields.Phone.isUpdateable())){
            ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER);
            update lstAccountToUpdate;
            ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER);
        }
        //update the contact point phone list if and only if one account has more than one primay marked
        //while inserting or updating contact point phone
        if(lstCPP.size()>0 && (Schema.sObjectType.ContactPointPhone.fields.IsPrimary.isUpdateable())){
            ASDAC_TriggerHandler.bypass(PHONE_HANDLER);
            update lstCPP;
            ASDAC_TriggerHandler.clearBypass(PHONE_HANDLER);
        }
        
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         ContactPointPhone List
@return        void
@description   This method is to blank the phone field on account if the primary contactpointphone is deleted
**********************************************************************************************/
    private void blankPhoneOnPrimaryDelete(List<ContactPointPhone> oldList){
        Set<Id> parentIds = new Set<Id>();
        for(ContactPointPhone cpp : oldList){
            if(cpp.IsPrimary == true){
                parentIds.add(cpp.ParentId);
            }
        }
        if(!parentIds.isEmpty()) {
            List<Account> lstAccountToUpdate = new List<Account>();
            for(Id objId :parentIds){
                lstAccountToUpdate.add(new Account(Id = objId, Phone = ''));
            }
            if(lstAccountToUpdate.size()>0 && (Schema.sObjectType.Account.fields.Phone.isUpdateable())){
                ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER);
                update lstAccountToUpdate;
                ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER);

            }
        }
    }
}