public with sharing class ASDAC_ContactPointAddressTriggerHandler extends ASDAC_TriggerFramworkService {
private Map<Id, ContactPointAddress> newCPAMap;
    private Map<Id, ContactPointAddress> oldCPAMap;
    private List<ContactPointAddress> lstCPA;
    private List<ContactPointAddress> lstOldCPA;
    private static final string ACCOUNT_HANDLER = 'ASDAC_AccountTriggerHandler';
    private static final string ADDRESS_HANDLER = 'ASDAC_ContactPointTriggerAddressHandler';
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is constructor of the class.
**********************************************************************************************/ 
    public ASDAC_ContactPointAddressTriggerHandler() {
        this.newCPAMap = (Map<Id, ContactPointAddress>) Trigger.newMap;
        this.oldCPAMap = (Map<Id,ContactPointAddress>) Trigger.oldMap;
        this.lstCPA = (List<ContactPointAddress>) Trigger.new;
        this.lstOldCPA = (List<ContactPointAddress>) Trigger.old;
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides beforeInsert Trigger
**********************************************************************************************/     
    public override void beforeInsert() {
        try{
            validateAddressTypeAndUsageTypeFields(lstCPA);
            updateDefaultAddress(lstCPA);
            updateDeliveryStoreID(lstCPA);
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
            validateAddressTypeAndUsageTypeFields(lstCPA);
            updateDefaultAddress(lstCPA);
            updateDeliveryStoreID(lstCPA);
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
        ASDAC_CommonUtility.deleteConsents(oldCPAMap,ASDAC_GlobalConstants.OBJCONTACTPOINTADDRESS);
        updateDeliveryStoreID(lstOldCPA);
    }
/**********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@return        void
@description   This method overrides afterDelete Trigger
**********************************************************************************************/
    public override void afterDelete() {
        try{
            blankAddressFieldsOnDefaultDelete(lstOldCPA);
        }catch(Exception ex){
            ASDAC_Logger.logException(ex);
        }
    }

/**********************************************************************************************
@author        Sapient: Ramdev Chahar
@date          9 June 2022
@param         ContactPointAddress List
@return        void
@description   This method is used to validate the picklist values of addresstype and UsageType Fields
**********************************************************************************************/
    private void validateAddressTypeAndUsageTypeFields(List<ContactPointAddress> cpaList) {
        Set<String> addressTypeValues= new Set<String>();
        Set<String> usageTypeValues= new Set<String>();
        Schema.DescribeFieldResult fieldResult1 = ContactPointAddress.addressType.getDescribe();
        Schema.DescribeFieldResult fieldResult2 = ContactPointAddress.usageType.getDescribe();
        List<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple1){
            addressTypeValues.add(pickListVal.getLabel());
        }
        for( Schema.PicklistEntry pickListVal : ple2){
            usageTypeValues.add(pickListVal.getLabel());
        }
        for(ContactPointAddress cpa :cpaList){
            if(cpa.AddressType != null && !addressTypeValues.contains(cpa.AddressType) ){
                cpa.AddressType.adderror( ASDAC_GlobalConstants.FIELDADDRESSTYPE +  ' : '+ASDAC_GlobalConstants.ERRORRESTRICTEDPICKLIST +':'+ cpa.AddressType);
            }
            if(cpa.UsageType != null && !usageTypeValues.contains(cpa.UsageType) ){
                cpa.UsageType.adderror( ASDAC_GlobalConstants.FIELDUSAGETYPE + ' : '+ASDAC_GlobalConstants.ERRORRESTRICTEDPICKLIST +':'+ cpa.UsageType);
            }
        }
    }
/**********************************************************************************************
@author        Sapient: Ramdev Chahar
    @date          20 Jan 2023
    @param         ContactPointAddress List
    @return        void
    @description   This method is to blank the address fields on account if the default contactpointaddress is deleted
**********************************************************************************************/
    private void blankAddressFieldsOnDefaultDelete(List<ContactPointAddress> oldList){
        Set<Id> parentIds = new Set<Id>();
        for(ContactPointAddress cpa : oldList){
            if(cpa.IsDefault == true){
                parentIds.add(cpa.ParentId);
            }
        }
        
        List<Account> lstAccountToUpdate = new List<Account>();
        for(Id objId :parentIds){
            Account objAccount = new Account(Id = objId);
            objAccount.AddressLine1__pc = ''; 
            objAccount.AddressLine2__pc = '';
            objAccount.AddressLine3__pc = '';
            objAccount.City__pc = '';
            objAccount.Country__pc = '';
            objAccount.PostalCode__pc = '';
            objAccount.State__pc = '';
            lstAccountToUpdate.add(objAccount);
        }
        if(lstAccountToUpdate.size()>0 && (Schema.sObjectType.Account.isUpdateable())){
            ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER);
            update lstAccountToUpdate;
            ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER);
        }
    }
/**********************************************************************************************
@author        Sapient: Ramdev Chahar
@date          20 Jan 2023
@param         ContactPointAddress List
@return        void
@description   This method is to unmark old default addresses when new address is marked as default
**********************************************************************************************/
    private void updateDefaultAddress(List<ContactPointAddress> cpaList){
        Set<Id> setIds = new Set<Id>();
        Set<Id> setParentIds = new Set<Id>();
        for(ContactPointAddress cpa :cpaList){
            if(cpa.isDefault && cpa.ParentId != null){
                if(cpa.Id != null){
                    setIds.add(cpa.Id);
                }
                setParentIds.add(cpa.ParentId);
            }
        }
        List<ContactPointAddress> lstCPA = [SELECT Id, IsDefault FROM ContactPointAddress WHERE IsDefault = true and ParentId in :setParentIds and Id NOT in :setIds WITH SECURITY_ENFORCED];
        if(lstCPA.size()>0){
            for(ContactPointAddress cpa : lstCPA){
                cpa.IsDefault = false;
                cpa.UpdatedDatetime__c = System.now();
            }
            if(Schema.sObjectType.ContactPointAddress.fields.IsDefault.isUpdateable()){
                ASDAC_TriggerHandler.bypass(ADDRESS_HANDLER);
                update lstCPA;
                ASDAC_TriggerHandler.clearBypass(ADDRESS_HANDLER);  
            }    
        }   
    }
    /**********************************************************************************************
@author        TCS: Rohit Funde
@date          25 Feb 2025
@param         ContactPointAddress List
@return        void
@description   This method is to Update DeliveryStoreId when records of ContactPointAddress object are either inserted or updated
**********************************************************************************************/
private void updateDeliveryStoreID(List<ContactPointAddress> cpaList) {
    try {
        Map<String, List<Id>> postalCodeToCpaIds = extractPostalCodesAndIds(cpaList);
        
        Map<String, StoreCatchment__c> postalCodeToStoreMap = getStoreCatchmentMap(postalCodeToCpaIds.keySet());
        
        processInsertRecords(cpaList, postalCodeToStoreMap);
        processUpdateRecords(postalCodeToCpaIds);
    } catch (Exception e) {
        System.debug('Error in updateDeliveryStoreID: ' + e.getMessage());
    }
}

private Map<String, List<Id>> extractPostalCodesAndIds(List<ContactPointAddress> cpaList) {
    Map<String, List<Id>> postalCodeToCpaIds = new Map<String, List<Id>>();
    for (ContactPointAddress cpa : cpaList) {
        if (cpa.DeliveryStoreId__c == null && cpa.PostalCode__c != null) {
            String cleanPostalCode = cpa.PostalCode__c.trim().toUpperCase();
            if (!postalCodeToCpaIds.containsKey(cleanPostalCode)) {
                postalCodeToCpaIds.put(cleanPostalCode, new List<Id>());
            }
            postalCodeToCpaIds.get(cleanPostalCode).add(cpa.Id);
        }
    }
    return postalCodeToCpaIds;
}

private Map<String, StoreCatchment__c> getStoreCatchmentMap(Set<String> postalCodes) {
    Map<String, StoreCatchment__c> postalCodeToStoreMap = new Map<String, StoreCatchment__c>();
    if (!postalCodes.isEmpty()) {
        for (StoreCatchment__c sc : [SELECT StoreNumber__c, PostalCode__c FROM StoreCatchment__c WHERE PostalCode__c IN :postalCodes]) {
            postalCodeToStoreMap.put(sc.PostalCode__c, sc);
        }
    }
    return postalCodeToStoreMap;
}

private void processInsertRecords(List<ContactPointAddress> cpaList, Map<String, StoreCatchment__c> postalCodeToStoreMap) {
    if (!Trigger.isInsert) return;

    for (ContactPointAddress cpa : cpaList) {
        if (cpa.DeliveryStoreId__c != null || cpa.PostalCode__c == null) {
            continue;
        }

        String cleanPostalCode = cpa.PostalCode__c.trim().toUpperCase();
        StoreCatchment__c matchedStore = postalCodeToStoreMap.get(cleanPostalCode);

        if (matchedStore != null && matchedStore.StoreNumber__c != null) {
            cpa.DeliveryStoreId__c = matchedStore.StoreNumber__c.substring(0, Math.min(4, matchedStore.StoreNumber__c.length()));
        }
    }
}

private void processUpdateRecords(Map<String, List<Id>> postalCodeToCpaIds) {
    if (!Trigger.isUpdate || postalCodeToCpaIds.isEmpty()) return;

    List<Id> cpaIdsForAsyncUpdate = new List<Id>();
    for (List<Id> ids : postalCodeToCpaIds.values()) {
        cpaIdsForAsyncUpdate.addAll(ids);
    }

    if (!cpaIdsForAsyncUpdate.isEmpty()) {
        ASDAC_UpdateDeliveryStoreID.updateDeliveryStoreIdAsync(cpaIdsForAsyncUpdate);
    }
}
}