/* *********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is ContactPointEmail Object Trigger Handler Class contains business logic.
**********************************************************************************************/
public with sharing class ASDAC_ContactPointEmailHandler extends ASDAC_TriggerHandlerBase {
 	/**********************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          18 July 2022
    @param         ASDAC_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger

    **********************************************************************************************/
    public override void mainEntry(ASDAC_TriggerHandlerObj inputParam) {
        try {
            
            if (inputParam.isInsert && inputParam.isBefore) {
                validateDuplicateEmail((List<ContactPointEmail>)inputParam.newlist);
            }
            if (inputParam.isInsert && inputParam.isAfter) {
                updateIsPrimary((List<ContactPointEmail>)inputParam.newlist);                
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                validateDuplicateEmail((List<ContactPointEmail>)inputParam.newlist);
            }
            if (inputParam.isUpdate && inputParam.isAfter) {
                updateIsPrimary((List<ContactPointEmail>)inputParam.newlist);
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                //to delete ContactPointEmail related ContactPointConsent records and
                //add the error message to the Log__c object if ContactPointConsent deletion fails
                deleteConsents(inputParam);            
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
    @param         ContactPointEmail List
    @return        void
    @description   This method is to update is primary field on ContactPointEmail

    **********************************************************************************************/
    private void updateIsPrimary(List<ContactPointEmail> newList){
        Set<Id> parentIds = new Set<Id>();
        for(ContactPointEmail cpe : newList){
            parentIds.add(cpe.ParentId);
        }
        List<ContactPointEmail> cpeListToUpdate  = new List<ContactPointEmail>();
        List<Account> accountList = [SELECT Id, Loginid__c, 
                                        (SELECT Id, EmailAddress,IsPrimary, ParentId 
                                         FROM ContactPointEmails) 
                                     FROM Account 
                                     WHERE Id IN :parentIds 
                                     WITH SECURITY_ENFORCED];
        for(Account acc : accountList){
            for(ContactPointEmail cpe: acc.ContactPointEmails){
                if(cpe.EmailAddress == acc.Loginid__c && cpe.IsPrimary == false ){
                    cpe.IsPrimary = true;
                    cpeListToUpdate.add(cpe);
                }else if(cpe.IsPrimary == true && cpe.EmailAddress != acc.Loginid__c){
                    cpe.IsPrimary = false;
                    cpeListToUpdate.add(cpe);
                }
            }
        }
        if(cpeListToUpdate.size()>0 && (Schema.sObjectType.ContactPointEmail.fields.IsPrimary.isUpdateable())){
            update cpeListToUpdate;
        }
    }
    
    /**********************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          18 July 2022
    @param         ContactPointEmail List
    @return        void
    @description   This method is to validate email duplication

    **********************************************************************************************/
   private void validateDuplicateEmail(List<ContactPointEmail> newList){
        Set<Id> parentIds = new Set<Id>();
        Set<Id> cpeIds = new Set<Id>();
        //populate the parentIds and cpeIds Sets
        for(ContactPointEmail cpe : newList){
            parentIds.add(cpe.ParentId);
            cpeIds.add(cpe.Id);
        }
        Map<Id, Set<String>> mapOfIdToEmails = new Map<Id, Set<String>>();

        //Fetch all other records which are not triggered
        List<ContactPointEmail> cpeList = [SELECT Id, EmailAddress, ParentId 
                                           FROM ContactPointEmail 
                                           WHERE Id NOT IN :cpeIds 
                                           AND ParentId IN :parentIds 
                                           WITH SECURITY_ENFORCED];
        for(ContactPointEmail cpe: cpeList){
            //filter out records with null EmailAddress
            if(cpe.EmailAddress != null){
                Set<String> tempSet = mapOfIdToEmails.containsKey(cpe.ParentId) ? mapOfIdToEmails.get(cpe.ParentId) : new Set<String>();
                tempSet.add(cpe.EmailAddress);
                mapOfIdToEmails.put(cpe.ParentId, tempSet );
            }
        }
        //Reset the tempSet for reuse
        for(ContactPointEmail cpe : newList){
            Set<String> tempSet = mapOfIdToEmails.containsKey(cpe.ParentId) ?  mapOfIdToEmails.get(cpe.ParentId) : new Set<String>();
            if (tempSet.contains(cpe.EmailAddress)) {
                cpe.EmailAddress.addError(ASDAC_GlobalConstants.DUPLICATE_EMAIL);
            } else {
                tempSet.add(cpe.EmailAddress);
                mapOfIdToEmails.put(cpe.ParentId, tempSet);
            }
        }
    }

    /**********************************************************************************************
    @author        Sapient: Kishor Chand
    @date          30 Oct 2022
    @param         ASDAC_TriggerHandlerObj inputParam - To get the ContactPointEmail record list to 
                   be deleted.
    @return        void
    @description   This method is used to validate and add error when ContactPointEmail is Primary
    **********************************************************************************************/
    private void deleteConsents(ASDAC_TriggerHandlerObj inputParam) {
    List<ContactPointEmail> lstCPE = inputParam.oldList;
    for(ContactPointEmail objCPE: lstCPE) {
        if(objCPE.IsPrimary == true) {
            objCPE.addError(ASDAC_GlobalConstants.PRIMARY_EMAIL_DELETE_ERROR);
        }
    }
    ASDAC_CommonUtility.deleteConsents((Map<Id, ContactPointEmail>)inputParam.oldMap,ASDAC_GlobalConstants.OBJCONTACTPOINTEMAIL);
  }
}