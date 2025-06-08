public with sharing class ASDAC_ContactPointPhoneHandler extends ASDAC_TriggerHandlerBase {
/**********************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          18 July 2022
    @param         ASDAC_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger

    **********************************************************************************************/
    
    public static final string ACCOUNT_HANDLER = 'ASDAC_AccountHandler';
    public static final string CPP_HANDLER = 'ASDAC_ContactPointPhoneHandler';
    
    public override void mainEntry(ASDAC_TriggerHandlerObj inputParam) {
        try {
            
            if (inputParam.isInsert && inputParam.isAfter) {
                updateIsPrimary((List<ContactPointPhone>)inputParam.newlist, null);                
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                updateIsPrimary((List<ContactPointPhone>)inputParam.newlist, (Map<Id, ContactPointPhone>)inputParam.oldMap);
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                // Delete all consent related to ContactPointPhone and create and insert the Log__c
                //object if error occurs.
                ASDAC_CommonUtility.deleteConsents((Map<Id, ContactPointPhone>)inputParam.oldMap, ASDAC_GlobalConstants.OBJCONTACTPOINTPHONE);
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                blankPhoneOnPrimaryDelete((List<ContactPointPhone>)inputParam.oldlist);
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
    @date          18 July 2022
    @param         ContactPointPhone List
    @return        void
    @description   This method is to update is primary field on ContactPointPhone and accordingly
                   reflect the primary Phone number on the parent account Phone field.
    **********************************************************************************************/
    private void updateIsPrimary(List<ContactPointPhone> newList,Map<Id, ContactPointPhone> oldMap ){
        //To store the parent accountIds of the ContactPointPhone 
        Set<Id> parentIds = new Set<Id>();
        Map<Id, String> mapAccountIdToPhone = new Map<Id, String>();
        for(ContactPointPhone cpp : newList){
            if(cpp.IsPrimary == true && (oldMap == null || oldMap.get(cpp.Id).IsPrimary == false)){
                parentIds.add(cpp.ParentId);
                mapAccountIdToPhone.put(cpp.ParentId, cpp.TelephoneNumber);
            }
        }
        
        List<ContactPointPhone> lstCPP = [SELECT Id, IsPrimary, ParentId, TelephoneNumber 
                                          FROM ContactPointPhone
                                          WHERE ParentId IN :parentIds AND IsPrimary = true AND Id not in :newList
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
            ASDAC_TriggerHandler.bypass(CPP_HANDLER);
            update lstCPP;
            ASDAC_TriggerHandler.clearBypass(CPP_HANDLER);
        }

    }
    /**********************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          18 Jan 2023
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