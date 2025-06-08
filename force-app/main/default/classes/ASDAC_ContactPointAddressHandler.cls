/* *********************************************************************************************
@author        Sapient: Sanjeev Shukla
@date          14 June 2023
@description   This is ContactPointAddress Object Trigger Handler Class contains business logic.
********************************************************************************************* */
public with sharing class ASDAC_ContactPointAddressHandler extends ASDAC_TriggerHandlerBase {
   /**********************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          7 June 2022
    @param         ASDAC_TriggerHandlerObj inputParam
    @return        void
    @description   This method is used to invoke method from trigger

    **********************************************************************************************/
    public static final string ACCOUNT_HANDLER = 'ASDAC_AccountHandler';
    public override void mainEntry(ASDAC_TriggerHandlerObj inputParam) {
        try {
            if (inputParam.isInsert && inputParam.isBefore) {
                validateAddressTypeAndUsageTypeFields((List<ContactPointAddress>)inputParam.newList);
            }
            if (inputParam.isUpdate && inputParam.isBefore) {
                validateAddressTypeAndUsageTypeFields((List<ContactPointAddress>)inputParam.newList);
            }
            if (inputParam.isDelete && inputParam.isBefore) {
                // Delete all consent related to ContactPointAddress and create and insert the Log__c
                //object if error occurs.
                ASDAC_CommonUtility.deleteConsents((Map<Id, ContactPointAddress>)inputParam.oldMap,ASDAC_GlobalConstants.OBJCONTACTPOINTADDRESS);
            }
            if (inputParam.isDelete && inputParam.isAfter) {
                blankAddressFieldsOnDefaultDelete((List<ContactPointAddress>)inputParam.oldList);
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
}