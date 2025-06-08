/************************************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2024-02-14
* @description                  : ASDAC-11725 Bulk Calculate the amount we have to Refund after saving Gurantee calculatio.
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                14-Feb-2024      Created the class
***************************************************************************************************/
public with sharing class ASDAC_SavingGuranteeBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {
    Public  Map<Id,ASDAC_LoyaltyGetOrderListWrapper> customerOrderListMap = new  Map<Id,ASDAC_LoyaltyGetOrderListWrapper>();
    List<Id> assetIds = new List<Id>();
    ASDAC_LoyaltyGetOrderListWrapper responseBody = new ASDAC_LoyaltyGetOrderListWrapper();
    public ASDAC_SavingGuranteeBatch(Map<Id,ASDAC_LoyaltyGetOrderListWrapper> responseMap, List<Id> assetId){
        this.customerOrderListMap = responseMap;
        this.assetIds = assetId;
    }
    
    String assetQuery = 'select Id,AssetLevel,AccountId,UsageEndDate,Is_Saving_Guarantee_Issued__c,ContactId,Product2.ItemId__c,isMigratedSubscription__c,PurchaseDate,Status,Product2.PassGuarantee__c,Product2.PlanPrice__c,loyaltyOrderNumber__c,Product2.NumberOfInstallments__c,Migrated_Savings__c,Recurring_Slot_Status__c,Is_1_skipped__c,Is_2_skipped__c, Is_3_skipped__c,Recurring_Slot_1__c,Recurring_Slot_End__c,Recurring_Slot_Frequency__c,Recurring_Slot_Id__c,Recurring_Slot_Start__c,Recurring_Slot_Template_Id__c,seq_counter__c from Asset where id IN:assetIds';
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(assetQuery);
    }
    public void execute(Database.BatchableContext context, List<Asset> lstAsset) {
        for(Asset ast :lstAsset){
            this.responseBody = this.customerOrderListMap.get(ast.ContactId);
            ASDAC_SavingGurantee.getSavingGurantee(this.responseBody,ast);
        }       
    }
    public void finish(Database.BatchableContext context){
    }
}