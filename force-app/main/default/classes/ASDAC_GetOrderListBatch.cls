/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2024-02-14
* @description                  : ASDAC-15573 - Bulk GetOrderList PS AIS Endpoint (Savings Guarantee)
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                22-Dec-2023      Created the class
***************************************************************************************************/
public with sharing class ASDAC_GetOrderListBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful {
    List<Id> assetIds;
    public ASDAC_GetOrderListBatch(List<Id> assetIds){
        this.assetIds = assetIds;
    }
    String assetQuery = 'select Id,AssetLevel,AccountId,ContactId,Product2.ItemId__c,isMigratedSubscription__c,PurchaseDate,Status,Product2.PassGuarantee__c,Product2.PlanPrice__c from Asset where id IN:assetIds';
   Map<Id,ASDAC_LoyaltyGetOrderListWrapper> customerOrderListMap = new  Map<Id,ASDAC_LoyaltyGetOrderListWrapper>();
    public Database.QueryLocator start(Database.BatchableContext context) {
        
        return Database.getQueryLocator(assetQuery);
    }
    public void execute(Database.BatchableContext context, List<Asset> lstObject) {
        for(Asset ast : lstObject){
            ASDAC_LoyaltyGetOrderListWrapper responseBody = ASDAC_GetOrderList.getOrderList(ast.ContactId);
            customerOrderListMap.put(ast.ContactId,responseBody); 
        }
    }
    public void finish(Database.BatchableContext context){
        ASDAC_SavingGuranteeBatch dpVoucher = new ASDAC_SavingGuranteeBatch(customerOrderListMap,assetIds);
        Database.executeBatch(dpVoucher,1);
    }
}