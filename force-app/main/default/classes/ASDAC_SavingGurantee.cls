/************************************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-05-19
* @description                  : ASDAC-11725 Calculate the amount we have to Refund after saving Gurantee calculation.
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                19-May-2023      Created the class
***************************************************************************************************/
public with sharing class ASDAC_SavingGurantee Implements Queueable, Database.AllowsCallouts {
    public ASDAC_LoyaltyGetOrderListWrapper responseBody;
    public  Asset asst;
    public static Decimal totalDiscountOnDelivery =0;
    public static boolean deliveryPassUsedFlag = false;
    public ASDAC_SavingGurantee(ASDAC_LoyaltyGetOrderListWrapper response, Asset asst){
        this.responseBody = response;
        this.asst = asst;
    }
    Public static List<Id> asstIds = new List<Id>();
    Public static Decimal billedAmount=1;
    @InvocableMethod(label = 'SavingGurantee')
    public static void dpSavinngGurantee(List<Id> assetIds){
        asstIds = assetIds;
        Integer numberOfAsset = asstIds.size();
        Boolean isDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('SavingsGuaranteeDisable').ASDAC_LoyaltySwitch__c;
        if(!isDisable){
            if(numberOfAsset==1){
                Asset asst = [select Id,AssetLevel,AccountId,UsageEndDate,Is_Saving_Guarantee_Issued__c,ContactId,Product2.ItemId__c,isMigratedSubscription__c,PurchaseDate,Status,Product2.PassGuarantee__c,Product2.PlanPrice__c,loyaltyOrderNumber__c,Product2.NumberOfInstallments__c,Migrated_Savings__c,Recurring_Slot_Status__c,Is_1_skipped__c,Is_2_skipped__c, Is_3_skipped__c,Recurring_Slot_1__c,Recurring_Slot_End__c,Recurring_Slot_Frequency__c,Recurring_Slot_Id__c,Recurring_Slot_Start__c,Recurring_Slot_Template_Id__c,seq_counter__c from Asset where id IN:asstIds Limit 1];
                if(!Test.isRunningTest()){
                    System.enqueueJob(new ASDAC_GetOrderList(asst)); 
                }   
            }else if(numberOfAsset>1){
                ASDAC_GetOrderListBatch orderList = new ASDAC_GetOrderListBatch(asstIds);
                Database.executeBatch(orderList,1);
            }
        }     
        
    }
    public void execute(QueueableContext context) {
        getSavingGurantee(this.responseBody,this.asst);
    }
    
    Public static void getSavingGurantee(ASDAC_LoyaltyGetOrderListWrapper responseBody, Asset asst){
        try{
            if(asst.Migrated_Savings__c>0){
                totalDiscountOnDelivery = asst.Migrated_Savings__c;
                deliveryPassUsedFlag = true;
            }   
            calculateSavingGurantee(responseBody,asst); 
            //Code added to cancel recurring slot
            if(asst.Recurring_Slot_Status__c == 'Active'){

                System.enqueueJob(new ASDAC_RSNullifyBatch(asst)); 
            }
        }catch (Exception ex){
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_LOYALTY, 'guarantee calculation issue', 'ASDAC_SavingGurantee');
            ASDAC_Logger.writeLogsToDatabase();
            
        }
    } 
    
    public static void calculateSavingGurantee(ASDAC_LoyaltyGetOrderListWrapper responseBody , Asset asst){
        
        if(!Test.isrunningTest()){
            if(asst.Status == 'Expired' && asst.Product2.NumberOfInstallments__c>1){
                billedAmount = [Select Id,UnitPrice,BillingPeriodAmount,BilledAmount from BillingSchedule where ReferenceEntityId = :asst.loyaltyOrderNumber__c limit 1].UnitPrice;
            }
            else{
                billedAmount = [Select Id,UnitPrice,BillingPeriodAmount,BilledAmount from BillingSchedule where ReferenceEntityId = :asst.loyaltyOrderNumber__c limit 1].BillingPeriodAmount;
            }  
        }
        Boolean eligibleForSG = asst.Product2.PassGuarantee__c;
        
        Integer daysbeforeSubscriptionPurchase = Date.valueOf(asst.PurchaseDate).daysBetween(date.today());
        Integer coolingPeriod =Integer.valueOf(system.Label.CoolingPeriodForSavingGurantee);
        
        Decimal issueVoucherAmount = 0.0;
        
        if(eligibleForSG ==true && asst.Status == 'Cancelled' && daysbeforeSubscriptionPurchase <= coolingPeriod ){
            //call ,ethod to canculate total DiscountAmount on Orders
            getTotalDiscountAmount(responseBody ,asst);
            // call helper Method
            issueVoucherAmount = calculateSavingGuranteeHelper(asst,deliveryPassUsedFlag,totalDiscountOnDelivery);
        }else if(eligibleForSG ==true && asst.Status == 'Expired' && asst.Is_Saving_Guarantee_Issued__c==false ){
            getTotalDiscountAmount(responseBody ,asst);
            Decimal voucherAmount = billedAmount - totalDiscountOnDelivery;
            issueVoucherAmount = voucherAmount;
            if(!Test.isrunningTest() && issueVoucherAmount > 0){ 
                ASDAC_GoodWillWalletIdentity.callEagleEyeForVoucher(asst.AccountId,Integer.valueOf(issueVoucherAmount*100) ,'Savings_Guarantee','');
            }
        }
        if(deliveryPassUsedFlag || asst.Status == 'Expired' || asst.isMigratedSubscription__c){
            asst.Refund_SavingGuranteeAmount__c = issueVoucherAmount;
            update asst; 
        }
    }
    
    //Calculate saving gurantee Helper class
    public static decimal calculateSavingGuranteeHelper(Asset asst,Boolean deliveryPassUsedFlag,Decimal totalDiscountOnDelivery){
        
        Decimal issueVoucherAmount=0.0;
        
        if(deliveryPassUsedFlag == false ){
            if(asst.isMigratedSubscription__c && !Test.isrunningTest()){  
                ASDAC_GoodWillWalletIdentity.callGHSVoucher(asst.AccountId,Integer.valueOf(billedAmount*100) ,'Refund','');
                
            }else if(!Test.isrunningTest()){
                ASDAC_DeliveryPassRefundCallout.initiateRefund(asst.id);
            }
            
        }else if(deliveryPassUsedFlag == true){
            Decimal voucherAmount = billedAmount - totalDiscountOnDelivery;
            issueVoucherAmount = voucherAmount; 
            if(!Test.isrunningTest() && issueVoucherAmount > 0){
                ASDAC_GoodWillWalletIdentity.callGHSVoucher(asst.AccountId,Integer.valueOf(issueVoucherAmount*100) ,'Refund',''); 
            }
        } 
        return issueVoucherAmount;
    }
    public static void getTotalDiscountAmount(ASDAC_LoyaltyGetOrderListWrapper responseBody,Asset asst){
        System.debug(responseBody);
        System.debug('asst : '+asst);
        if(responseBody.data!=null && asst.status=='Cancelled'){
            getRefundAmount(responseBody, asst);
        }else if(responseBody.data!=null && asst.status=='Expired'){
            getSavingGuranteeAmount(responseBody, asst);
        }
    }
    public static void getRefundAmount(ASDAC_LoyaltyGetOrderListWrapper responseBody,Asset asst){
        for(ASDAC_LoyaltyGetOrderListWrapper.Datalist orddetail :responseBody.data){
            if(Date.valueOf(orddetail.orderDate) >= Date.valueOf(asst.PurchaseDate) && orddetail.deliveryPassUsed == true && orddetail.orderStatus != 'CREATED' && orddetail.orderStatus != 'CANCELLED' && Date.valueOf(orddetail.orderDate) <= Date.valueOf(asst.UsageEndDate)){                    
                totalDiscountOnDelivery +=orddetail.discountedPrice;
                deliveryPassUsedFlag = true;
            }    
        }  
    }
    public static void getSavingGuranteeAmount(ASDAC_LoyaltyGetOrderListWrapper responseBody,Asset asst){
        for(ASDAC_LoyaltyGetOrderListWrapper.Datalist orddetail :responseBody.data){
            if(Date.valueOf(orddetail.orderDate) >= Date.valueOf(asst.PurchaseDate) && orddetail.deliveryPassUsed == true && orddetail.orderStatus == 'SETTLED' && Date.valueOf(orddetail.orderDate) <= Date.valueOf(asst.UsageEndDate)){                    
                totalDiscountOnDelivery +=orddetail.discountedPrice;
                deliveryPassUsedFlag = true;
            }  
        }
    }
}