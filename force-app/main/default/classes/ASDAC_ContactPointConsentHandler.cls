public with sharing class ASDAC_ContactPointConsentHandler  extends ASDAC_TriggerHandlerBase {
    /**********************************************************************************************
       @author        Sapient: Ramdev Chahar
       @date          25 August 2022
       @param         ASDAC_TriggerHandlerObj inputParam
       @return        void
       @description   This method is used to invoke method from trigger
   
       **********************************************************************************************/
       public override void mainEntry(ASDAC_TriggerHandlerObj inputParam) {
           try {
               if (inputParam.isInsert && inputParam.isBefore) {
                   verifyContactPointIds((List<ContactPointConsent>)inputParam.newlist);
               }
              
               if (inputParam.isUpdate && inputParam.isBefore) {
                   verifyContactPointIds((List<ContactPointConsent>)inputParam.newlist);
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
       @date          25 August 2022
       @param         ContactPointConsent List
       @return        void
       @description   Verfiy the contactpointid before insertion or updation of a record
   
       **********************************************************************************************/
       private void verifyContactPointIds(List<ContactPointConsent> newList){
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
       @author        Sapient: Ramdev Chahar
       @date          25 August 2022
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