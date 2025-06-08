/**********************************************************************************************
@author         Dependra Singh
@date           11 May 2022
@description:   This Class is used to set and get trigger context variables
@revisions:     
**********************************************************************************************/
public with sharing class ASDAC_TriggerHandlerObj {
        public static Boolean enableOldTriggerFramework = false;
        public string triggerObject {get;set;}
        public boolean isBefore {get;set;}
        public boolean isDelete {get;set;}
        public Boolean isAfter{get;set;}
        public Boolean isInsert {get;set;}
        public Boolean isUpdate {get;set;}
        public Boolean isExecuting {get;set;}
        public List<SObject> newlist {get;set;}
        public Map<ID, SObject> newmap {get;set;}
        public List<SObject> oldlist {get;set;}
        public Map<ID,SObject> oldmap {get;set;}
    
}