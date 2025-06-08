/**********************************************************************************************
@author        TCS: Rohit Funde
@date          25 Feb 2025
@param         ContactPointAddress List
@return        void
@description   This method is to Update DeliveryStoreId based on the postal code whenever the ContactPointAddress is modified or updated
**********************************************************************************************/
public with sharing class ASDAC_UpdateDeliveryStoreID {
    @future
    public static void updateDeliveryStoreIdAsync(List<Id> cpaIds) {
        try {
            List<ContactPointAddress> addressesToUpdate = getContactPointAddresses(cpaIds);
            
            Set<String> postalCodes = extractPostalCodes(addressesToUpdate);
            
            Map<String, StoreCatchment__c> postalCodeToStoreMap = getStoreCatchmentMap(postalCodes);
            
            List<ContactPointAddress> updates = prepareUpdates(addressesToUpdate, postalCodeToStoreMap);
            
            if (!updates.isEmpty()) {
                update updates;
            }
        } catch (Exception e) {
            System.debug('Error in updateDeliveryStoreIdAsync: ' + e.getMessage());
        }
    }

    private static List<ContactPointAddress> getContactPointAddresses(List<Id> cpaIds) {
        return [SELECT Id, PostalCode__c, DeliveryStoreId__c FROM ContactPointAddress WHERE Id IN :cpaIds];
    }

    private static Set<String> extractPostalCodes(List<ContactPointAddress> addresses) {
        Set<String> postalCodes = new Set<String>();
        for (ContactPointAddress cpa : addresses) {
            if (cpa.DeliveryStoreId__c == null && cpa.PostalCode__c != null) {
                postalCodes.add(cpa.PostalCode__c.trim().toUpperCase());
            }
        }
        return postalCodes;
    }

    private static Map<String, StoreCatchment__c> getStoreCatchmentMap(Set<String> postalCodes) {
        Map<String, StoreCatchment__c> postalCodeToStoreMap = new Map<String, StoreCatchment__c>();
        if (!postalCodes.isEmpty()) {
            for (StoreCatchment__c sc : [SELECT StoreNumber__c, PostalCode__c FROM StoreCatchment__c WHERE PostalCode__c IN :postalCodes]) {
                postalCodeToStoreMap.put(sc.PostalCode__c, sc);
            }
        }
        return postalCodeToStoreMap;
    }

    private static List<ContactPointAddress> prepareUpdates(List<ContactPointAddress> addresses, Map<String, StoreCatchment__c> storeMap) {
        List<ContactPointAddress> updates = new List<ContactPointAddress>();
        for (ContactPointAddress cpa : addresses) {
            if (cpa.DeliveryStoreId__c == null && cpa.PostalCode__c != null) {
                String cleanPostalCode = cpa.PostalCode__c.trim().toUpperCase();
                if (storeMap.containsKey(cleanPostalCode)) {
                    StoreCatchment__c matchedStore = storeMap.get(cleanPostalCode);
                    if (matchedStore.StoreNumber__c != null) {
                        String shortenedStoreNumber = matchedStore.StoreNumber__c.substring(0, 4);
                        cpa.DeliveryStoreId__c = shortenedStoreNumber;
                        updates.add(cpa);
                    }
                }
            }
        }
        return updates;
    }
}