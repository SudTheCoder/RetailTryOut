/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2024-02-20
* @description                  : Batch class To run Monthly autorenew called from ASDAC_MonthlyInstallmentRetryFlow. 
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                20-Feb-2024      Created the class
***************************************************************************************************/
public with sharing class ASDAC_MonthlyInstallmentRetryBatch implements Database.batchable<sObject>,Database.AllowsCallouts, database.stateful {
    Date dt = System.today();
    Date dtOneDay = dt-1;
    public static final String REQUEST_TYPE = 'Monthly';
    Date montlyGracePeriod = Date.today().addDays(-Integer.valueOf(System.Label.ASDAC_LoyaltyMonthlyGracePeriod));
    
    @InvocableMethod(label = 'subscription Monthly Installemnt Retry')
    public static void subscriptionMonthlyInstallment(List<List<Id>> assetIds){
        ASDAC_MonthlyInstallmentRetryBatch monthlyRetry = new ASDAC_MonthlyInstallmentRetryBatch(assetIds[0]);
        Database.executeBatch(monthlyRetry,1);
    }
    List<Id> assetIds = new List<Id>();
    Public ASDAC_MonthlyInstallmentRetryBatch(List<Id> assetIds){
        this.assetIds = assetIds;
    }
    
    Map<id,String> mapAssetIdXML = new Map<Id,String>();
    public database.querylocator start(Database.BatchableContext objBatch){
        String queryfields = 'Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,Customer_Card__r.CardBrand__c,'+
            'PurchaseDate,Customer_Card__c,Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Installment_Payment_Status__c,'+
            'Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c,isMigratedSubscription__c,Installment_Payment_Counter__c,asda_merchant_reference_no__c,LoyaltyOrderNo__c';
        String query = 'SELECT '+queryfields+' FROM Asset where id IN :assetIds';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext objBatch, List<Asset> lstAssets){
        String strXML;
        try{
            Asset objAsset = lstAssets[0];
            if(objAsset.Customer_Card__c !=null){
                if(objAsset.isMigratedSubscription__c && objAsset.Payment_Id__c==null && objAsset.PSPID__c == null){
                    Map<String,string> migratedPaymentResponse = ASDAC_PaymentResponseWrapper.worldlineAuthenticationRequest(objAsset,REQUEST_TYPE);
                    if(migratedPaymentResponse != null && !migratedPaymentResponse.isempty()){
                        objAsset.Payment_Id__c = migratedPaymentResponse.get('paymentId');
                        objAsset.asda_merchant_reference_no__c =  migratedPaymentResponse.get('merchantReference');
                        strXML = ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset,REQUEST_TYPE,migratedPaymentResponse);
                        mapAssetIdXML.put(objAsset.id, strXML); 
                    }
                }else{
                    strXML = ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset,REQUEST_TYPE,null); 
                    mapAssetIdXML.put(objAsset.id, strXML);
                } 
            }
            objAsset.Installment_Payment_Status__c = 'Pending';
            update objAsset;
        }catch(Exception ex){
            system.debug('Error : '+ex.getMessage());
            system.debug('Error: '+ex.getStacktracestring());
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_LOYALTY, 'auto-renew issue', 'ASDAC_MonthlyInstallmentRetryBatch');
            ASDAC_Logger.writeLogsToDatabase();
            
            
        }
    }
    public void finish(Database.BatchableContext bc) {
        if(!this.mapAssetIdXML.isEmpty()){
            ASDAC_XMLCalloutBatch objCallout = new ASDAC_XMLCalloutBatch(this.mapAssetIdXML,'Monthly');
            Database.executeBatch(objCallout, 1);
        }   
    }
}