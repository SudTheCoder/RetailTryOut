public with sharing class ASDAC_OmsProgressMappingSelector {
    public static ASDAC_OmsProgressMapping__mdt findBy(String fulfillmentType, String orderStatus) {
        List<ASDAC_OmsProgressMapping__mdt> records = [SELECT StatusLabel__c, ProgressDot__c from ASDAC_OMSProgressMapping__mdt where FulfillmentType__c = :fulfillmentType and OrderStatus__c = :orderStatus];
        if (records.isEmpty()) {
            return null;
        }
        return records[0];
    }
}