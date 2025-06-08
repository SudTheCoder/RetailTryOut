/***********************************************************************************************************************
* author                       : Niteesh Kumar
* date                         : 2023-03-02
* Component Type               : Apex Class
* component Name               : ASDAC_MonthlyInstallmentPayments
* description                  : ASDAC-7358, ASDAC-8203 - GHS - DP SME - Monthly instalment payload along with Payment authorization
* @Modified By				   : Niteesh Kumar
************************************************************************************************************************/

public with sharing class ASDAC_MonthlyInstallmentPaymentsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{
    public static String orgDomain = Url.getSalesforceBaseUrl().toExternalForm();
    public static String invoiceUrl =  ASDAC_Loyalty_base_urls__mdt.getInstance('MonthlyInvoice').Traget_endpoint__c;
    List<Asset> cancelasstlist = new List<Asset>();
    public static final String CREATE_BILLING_PAYMENT_ENDPOINT = orgDomain+invoiceUrl;
    Public string asstId =null;
    public ASDAC_MonthlyInstallmentPaymentsBatch(){}
    public ASDAC_MonthlyInstallmentPaymentsBatch(String asstId){
        this.asstId = asstId;
    }
    
    public database.querylocator start(Database.BatchableContext objBatch){
        Date todaysDate = date.today();
        Date yesterdaydate = todaysDate.addDays(-1);
        System.debug('todaysDate : '+todaysDate +' yesterdaydate :'+yesterdaydate);
        String query; 
        String queryFields = 'SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,PurchaseDate';
        
        if(this.asstId==null){
            query = queryFields+' FROM Asset where (((Migrated_Next_Payment_Date__c=:todaysDate OR (Migrated_Next_Payment_Date__c=null AND DP_Cancellation_Type__c =\'Regular\' AND UsageEndDate = :yesterdaydate )) AND  isMigratedSubscription__c = true) OR Next_Payment_Date__c =:todaysDate) AND  Status = \'Active\'';
        }else{
            query = queryFields+' FROM Asset WHERE Id=:asstId';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext objBatch, List<Asset> astList){
        system.debug('assetList: '+astList);
        Asset asst = astList[0];
        try{
            if(asst.DP_Cancellation_Type__c == 'Regular'){
                asst.Status = 'Cancelled';
                cancelasstlist.add(asst);
            }else{
                String payload = createJsonPayload(asst);
                String sessionId = 'Bearer ' + UserInfo.getSessionId();
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                
                request.setEndpoint(CREATE_BILLING_PAYMENT_ENDPOINT);
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Authorization', sessionId);
                request.setBody(payload);
                
                HttpResponse response = http.send(request);
                if(response.getStatusCode()!=202){
                    throw new ASDAC_EmailNotificationException(response.getStatus()+' '+response.getStatusCode() +' '+response.getBody());
                }
            }
        }catch(Exception ex){
            System.debug('Error : '+ex.getMessage());
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_LOYALTY, 'Monthly invoice issue', 'ASDAC_MonthlyInstallmentPaymentsBatch');
            ASDAC_Logger.writeLogsToDatabase();
        }
    }
    public void finish(Database.BatchableContext bc) {
        if(!cancelasstlist.isEmpty()){
            Update cancelasstlist;
        }
    }
    
    public String createJsonPayload(Asset asst){
        String bsId;
        if(!test.isRunningTest()){
            bsId = [Select Id from BillingSchedule where ReferenceEntityId = :asst.loyaltyOrderNumber__c limit 1].Id;
        }else{
            bsId = 'test123';
        }
        JSONGenerator gen = JSON.createGenerator(true);
        String jsonbody;
        gen.writeStartObject();
        gen.writeFieldName('billingScheduleIds');
        gen.writeStartArray();
        gen.writeString(bsId); 
        gen.writeEndArray();
        gen.writeStringField('action','Posted');
        gen.writeStringField('correlationId','');
        if(asst.isMigratedSubscription__c &&  asst.Next_Payment_Date__c < asst.Migrated_Next_Payment_Date__c){
            Integer counter = 0;
            
            if(asst.Migrated_Next_Payment_Date__c.Day() < (asst.PurchaseDate).Day()){
                date previousMonthDate = (asst.Migrated_Next_Payment_Date__c).addMonths(-1);
                counter = (date.daysInMonth(previousMonthDate.year(),previousMonthDate.month()))+asst.Migrated_Next_Payment_Date__c.Day() - (asst.PurchaseDate).Day();
            }else{
                counter = (asst.Migrated_Next_Payment_Date__c).Day() - (asst.PurchaseDate).Day();
            }
            
            gen.writeStringField('targetDate', String.valueOf(asst.Migrated_Next_Payment_Date__c.addMonths(1).addDays(-counter-1)));
            gen.writeStringField('invoiceDate', String.valueOf(asst.Migrated_Next_Payment_Date__c.addDays(-counter)));
        }else{
            gen.writeStringField('targetDate', String.valueOf(asst.Next_Payment_Date__c.addMonths(1).addDays(-1)));
            gen.writeStringField('invoiceDate', String.valueOf(asst.Next_Payment_Date__c));
        }
        gen.writeEndObject();
        jsonbody = gen.getAsString();
        system.debug('jsonbody: '+jsonbody);
        return jsonbody;
    }
    
}