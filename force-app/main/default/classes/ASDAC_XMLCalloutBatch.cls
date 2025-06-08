/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-17
* @Component Type               : Apex Class
* @component Name               : ASDAC_XMLCalloutBatch
* @description                  : ASDAC-8013 - GHS - DP SME - Recurring Slot Cancellation Implementation 
* @Modified By                  : Deepakshi/Niteesh
* @Modified Date		         : 2023-03-22
***************************************************************************************************/
public with sharing class ASDAC_XMLCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    
    String strQuery = 'SELECT Id, Auto_Renew__c, shopOrderNumber__c,PurchaseDate,CardTokenUsed__c,UsageEndDate, AccountId,loyaltyOrderNumber__c,Product2Id FROM Asset WHERE Id IN:setAssetId';
    Set <Id> setAssetId = new Set<Id>();
    Map<Id, String> mapAssetXML = new Map<Id, String>();
    Set <Id> setParentAssetId = new Set<Id>(); // ASDAC-9740
    List<Asset> lstUpdatedAsset = new List<Asset>();
    String paymentType;
    //Default Constructor
    public ASDAC_XMLCalloutBatch(Map<Id, String> mapAssetXML, string paymentType){
        this.setAssetId = mapAssetXML.keyset();
        this.mapAssetXML = mapAssetXML;
        this.paymentType = paymentType;
    }
    
    //START
    public database.querylocator start(Database.BatchableContext objBatch){
        return Database.getQueryLocator(strQuery);
    }
    
    //EXECUTE
    public void execute(Database.BatchableContext objBatch, List<Asset> lstAssets){
        for(Asset objAsset : lstAssets) {
            String currentXML = mapAssetXML.get(objAsset.Id);
            //perform HTTP callout
            performAutorenewalAndMonthlyCallout(currentXML,paymentType);
            
        }
    }
    
    //FINISH
    public void finish(Database.BatchableContext objBatch) {
    }
    
    //Callout - Pass XML to AIS
    public void performAutorenewalAndMonthlyCallout(String strRequestBody,String paymentType){
        try{
            String endpoint;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            ASDAC_Loyalty_base_urls__mdt monthlyPayUrl = ASDAC_Loyalty_base_urls__mdt.getInstance('monthlypayment');
            endpoint = monthlyPayUrl.Traget_endpoint__c;
            
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setBody(strRequestBody);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200 ){
                System.debug(response.getHeader('X-Correlation-Id'));
            }
        }catch (Exception ex){
            system.debug('Exception '+ex.getMessage());
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_LOYALTY, 'Slot cancellation issue', 'ASDAC_XMLCalloutBatch');
            ASDAC_Logger.writeLogsToDatabase();
            
        }
    }
}