/* *********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is Consent Object Trigger Handler Class contains business logic.
********************************************************************************************* */
public with sharing class ASDAC_ContactPointConsentTriggerHandler extends ASDAC_TriggerFramworkService {
    private Map<Id, ContactPointConsent> oldContactPointConsentMap;
    private List<ContactPointConsent> lstNewContactPointConsent;
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is constructor of the class.
**********************************************************************************************/
    public ASDAC_ContactPointConsentTriggerHandler() {
        this.lstNewContactPointConsent = (List<ContactPointConsent>) Trigger.new;
        this.oldContactPointConsentMap = (Map<Id, ContactPointConsent>) Trigger.oldMap;
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides beforeInsert Trigger
**********************************************************************************************/
    public override void beforeInsert() {
        try{  
            verifyContactPointIds(lstNewContactPointConsent);
        }catch(Exception ex) {
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
            verifyContactPointIds(lstNewContactPointConsent);
        }catch(Exception ex) {
            ASDAC_Logger.logException(ex);
        }
    }
    
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         ContactPointConsent List
@return        void
@description   Verfiy the contactpointid before insertion or updation of a record
**********************************************************************************************/
    private void verifyContactPointIds(List<ContactPointConsent> newList){
        System.debug('Hiiii I am in verify');
        Set<Id> accountIds = new Set<Id>();
        for(ContactPointConsent cpc: newList){
            accountIds.add(cpc.account__c);
        }
        Map<Id, Id> mapOfCPIdsAndParentId = new Map<Id, Id>();
        for(ContactPointAddress cpa: (List<ContactPointAddress>)getContactPointRecords(ASDAC_GlobalConstants.OBJCONTACTPOINTADDRESS,accountIds)){
            mapOfCPIdsAndParentId.put(cpa.Id, cpa.ParentId);
        }
        for(ContactPointEmail cpe: (List<ContactPointEmail>)getContactPointRecords(ASDAC_GlobalConstants.OBJCONTACTPOINTEMAIL,accountIds)){
            mapOfCPIdsAndParentId.put(cpe.Id, cpe.ParentId);
        }
        for(ContactPointPhone cpp: (List<ContactPointPhone>)getContactPointRecords(ASDAC_GlobalConstants.OBJCONTACTPOINTPHONE,accountIds)){
            mapOfCPIdsAndParentId.put(cpp.Id, cpp.ParentId);
        }
        for(ContactPointConsent cpc: newList){
            Boolean isContainsKey = mapOfCPIdsAndParentId.containsKey(cpc.ContactPointId);
            if(cpc.Account__c != null && ( (!isContainsKey) || (isContainsKey && mapOfCPIdsAndParentId.get(cpc.ContactPointId) != cpc.Account__c))){
                cpc.ContactPointId.addError(ASDAC_GlobalConstants.INVALID_CONTACTPOINT);
            }
        }
    }
    
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@param         String Object Name, Set Of ID accountIds
@return        List of SObject
**********************************************************************************************/
    private List<SObject> getContactPointRecords(String objectName, Set<Id> accountIds){
           String query = 'SELECT Id, ParentId '+
                       'FROM '+objectName+' '+
                       'WHERE ParentId IN :accountIds'+' WITH SECURITY_ENFORCED';
        List<SObject> lstSobject = Database.query(String.escapeSingleQuotes(query));
        return lstSobject;
    }
}