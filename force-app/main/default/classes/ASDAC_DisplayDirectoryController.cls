public with sharing class ASDAC_DisplayDirectoryController {
    @AuraEnabled( cacheable=true )  
    public static List <ASDAC_FcDsvMappingWithLocationID__mdt> getRecords() {        
        return [SELECT Id, FcDsvName__c,ContactEmail__c, Type__c FROM ASDAC_FcDsvMappingWithLocationID__mdt];        
    }
}