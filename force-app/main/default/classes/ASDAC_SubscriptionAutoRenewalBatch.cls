/***********************************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-02
* @Component Type               : Apex Class
* @component Name               : ASDAC_SubscriptionAutoRenewalBatch
* @description                  : ASDAC-8813 - GHS - DP SME - Auto-renew payload along with Payment authorization - 3
* @Modified By                  : Niteesh(ASDAC-17669)
* @Modified Date		        : 2024-02-02
************************************************************************************************************************/
public class ASDAC_SubscriptionAutoRenewalBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    //Constants
    public static final Boolean blnTrue = true;
    public static final String REQUEST_TYPE = 'AutoRenew';
    //Variable Declaration
    Date dt = System.today();
    Date autoRenewalGracePeriod = Date.today().addDays(-Integer.valueOf(System.Label.ASDAC_LoyaltyAutoRenewalGracePeriod));
    
    Set<Id> setAssetId = new Set<Id>();
    Map<id,String> mapAssetIdXML = new Map<Id,String>();
    List<Asset> lstUpdatedRenewal = new List<Asset>(); // ASDAC_9740
    
    //START
    public database.querylocator start(Database.BatchableContext objBatch){
        String queryfields = 'Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,Customer_Card__r.CardBrand__c,'+
            'PurchaseDate,Customer_Card__c,Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,'+
            'Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c,isMigratedSubscription__c,isFirstWorldlineTransactionDone__c,Installment_Payment_Counter__c,asda_merchant_reference_no__c,LoyaltyOrderNo__c';
        
        String strQuery = 'SELECT '+queryfields+' FROM Asset '+
            'WHERE Auto_Renew__c = :blnTrue  AND status = \'Active\''+
            'AND UsageEndDate >= :autoRenewalGracePeriod '+
            'AND UsageEndDate < :dt';
        
        return Database.getQueryLocator(strQuery);
    }
    
    //EXECUTE
    public void execute(Database.BatchableContext objBatch, List<Asset> lstAssets){
        try{
            Asset objAsset = lstAssets[0];
            String strXML;
            if(objAsset.Is_Product_Active__c == true){
                if(objAsset.Customer_Card__c !=null){
                    if(objAsset.isMigratedSubscription__c && objAsset.PSPID__c==null && objAsset.Payment_Id__c==null){
                        Map<String,string> migratedPaymentResponse = ASDAC_PaymentResponseWrapper.worldlineAuthenticationRequest(objAsset,REQUEST_TYPE);
                        if(!migratedPaymentResponse.isempty() && migratedPaymentResponse != null){ 
                            objAsset.asda_merchant_reference_no__c =  migratedPaymentResponse.get('merchantReference');
                            objAsset.Payment_Id__c = migratedPaymentResponse.get('paymentId');
                            strXML = ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset,REQUEST_TYPE,migratedPaymentResponse);
                            mapAssetIdXML.put(objAsset.id, strXML);
                        }
                    }else{
                        strXML = ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset,REQUEST_TYPE,null); 
                        mapAssetIdXML.put(objAsset.id, strXML);
                    }                   
                }                
                objAsset.Renewal_Payment_Status__c = 'Pending';
            }else{
                objAsset.Status = 'Expired';
            }
            
            lstUpdatedRenewal.add(objAsset); 
        }catch(Exception ex){
            system.debug('Error : '+ex.getMessage());
            system.debug('Error: '+ex.getStacktracestring());
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_LOYALTY, 'auto renew issue', 'ASDAC_SubscriptionAutoRenewalBatch');
            ASDAC_Logger.writeLogsToDatabase();
            
            
        }
    }
    
    //FINISH
    public void finish(Database.BatchableContext bc) {
        try{
            if(!lstUpdatedRenewal.isEmpty()){
                update lstUpdatedRenewal;  
            }
        }catch(exception e){
            System.debug('Error : '+e.getMessage());
            ASDAC_Logger.logException(e, ASDAC_GlobalConstants.STRING_LOYALTY, 'auto renew issue', 'ASDAC_SubscriptionAutoRenewalBatch');
            ASDAC_Logger.writeLogsToDatabase();
            
        }
        if(!this.mapAssetIdXML.isEmpty()){
            ASDAC_XMLCalloutBatch objCallout = new ASDAC_XMLCalloutBatch(this.mapAssetIdXML,'AutoRenew');
            Database.executeBatch(objCallout, 1); 
        }    
    }
    
    //XML Object Wrapper
    public class XMLObjectParams{
        public Account objAccount = new Account();
        public Order objOrder = new Order();
        public Product2 objProduct = new Product2();
        public CustomerCard__c objcard = new CustomerCard__c();
        public OrderItem objOrderproduct = new OrderItem();
        public Invoice objInvoice = new Invoice();
        public Asset objasset = new Asset();       
    }
    
}