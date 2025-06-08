public with sharing class ASDAC_ContactPointEmailTriggerHandler extends ASDAC_TriggerFramworkService{
 	private Map<Id, ContactPointEmail> newContactPointEmailMap;
    private Map<Id, ContactPointEmail> oldContactPointEmailMap;
    private List<ContactPointEmail> lstNewContactPointEmail;
    private List<ContactPointEmail> lstOldContactPointEmail;
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is constructor of the class.
**********************************************************************************************/ 
    public ASDAC_ContactPointEmailTriggerHandler() {
        this.newContactPointEmailMap = (Map<Id, ContactPointEmail>) Trigger.newMap;
        this.lstNewContactPointEmail = (List<ContactPointEmail>) Trigger.new;
        this.oldContactPointEmailMap = (Map<Id, ContactPointEmail>) Trigger.oldMap;
        this.lstOldContactPointEmail = (List<ContactPointEmail>) Trigger.old;
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides beforeInsert Trigger
**********************************************************************************************/
    public override void beforeInsert() {
        try{   
            validateDuplicateEmail(lstNewContactPointEmail);
        }catch(Exception ex) {
            ASDAC_Logger.logException(ex);
        }
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides afterInsert Trigger
**********************************************************************************************/
    public override void afterInsert() {
        try{    
            updateIsPrimary(lstNewContactPointEmail);
        }catch(Exception ex){
            ASDAC_Logger.logException(ex);
        }
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides beforeUpdate Trigger
**********************************************************************************************/
    public override void beforeUpdate() {
        try{    
            validateDuplicateEmail(lstNewContactPointEmail);
        }catch(Exception ex) {
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
            updateIsPrimary(lstNewContactPointEmail);
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
        try{    
            deleteConsents(lstOldContactPointEmail,oldContactPointEmailMap);
        }catch(Exception ex) {
            ASDAC_Logger.logException(ex);
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
        List<ContactPointEmail> conEmails = [SELECT Id, EmailAddress,IsPrimary, TYPEOF Parent WHEN Account THEN Loginid__c END
                                            FROM ContactPointEmail 
                                            WHERE ParentId IN : parentIds WITH SECURITY_ENFORCED ];  
        for(ContactPointEmail cpe: conEmails){
            if(cpe.EmailAddress == cpe.Parent.get('Loginid__c') && cpe.IsPrimary == false ){
                cpe.IsPrimary = true;
                cpeListToUpdate.add(cpe);
            }else if(cpe.IsPrimary == true && cpe.EmailAddress != cpe.Parent.get('Loginid__c')){
                cpe.IsPrimary = false;
                cpeListToUpdate.add(cpe);
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
                mapOfIdToEmails.put(cpe.ParentId, tempSet);
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
    private void deleteConsents(List<ContactPointEmail> objOldList, Map<Id, ContactPointEmail> objOldMap) {
        List<ContactPointEmail> lstCPE = objOldList;
        for(ContactPointEmail objCPE: lstCPE) {
            if(objCPE.IsPrimary == true) {
                objCPE.addError(ASDAC_GlobalConstants.PRIMARY_EMAIL_DELETE_ERROR);
            }
        }
        ASDAC_CommonUtility.deleteConsents(objOldMap,ASDAC_GlobalConstants.OBJCONTACTPOINTEMAIL);
    }
  
}