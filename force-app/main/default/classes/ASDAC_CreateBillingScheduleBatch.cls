/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2024-07-25
* @description                  : ASDAC-21425- Batch class for BillingSchedule creation for DP data migration
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                25-July-2025      Created the class
***************************************************************************************************/
public class ASDAC_CreateBillingScheduleBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static String orgDomain = Url.getOrgDomainURL().toExternalForm();
    List<Id> OIIDS = new List<Id>();
    public static String billingUrl = '/services/data/v56.0/actions/custom/flow/CreateBillingSchedule';
    public static final String CREATE_BILLING_Schedule = orgDomain+billingUrl;
    public ASDAC_CreateBillingScheduleBatch(){}
    public ASDAC_CreateBillingScheduleBatch(List<Id> ordItems){
        this.OIIDS = ordItems;
    }
    //START
    public database.querylocator start(Database.BatchableContext objBatch){
        String query;
        if(!OIIDS.isEmpty()){
            query ='SELECT Id,Description,OrderId  from OrderItem where Id IN :OIIDS';
        }else{
            query ='SELECT Id,Description,OrderId  from OrderItem where createdBy.Name LIKE \'%Migration User%\' AND CreatedDate >= LAST_N_DAYS:2 AND Description = \'Retry BS\'';  
        }
        
        return Database.getQueryLocator(query);
    }
    //EXECUTE
    public void execute(Database.BatchableContext objBatch, List<OrderItem> itemlist){
        try{
            String payload = getJsonPayload1(itemlist);
            String sessionId = 'Bearer ' + UserInfo.getSessionId();
            Http http = new Http();
            httpRequest req = new httpRequest();
            req.setMethod('POST');
            req.setEndPoint(CREATE_BILLING_Schedule);
            req.setBody(payload);
            req.setHeader('Content-Type', 'application/json; charset=utf-8');
            req.setHeader('Authorization', sessionId);
            req.setTimeout(20000);
            httpResponse response = http.send(req);
            system.debug(response.getBody());
        }catch(exception ex){
           system.debug('Error '+ex.getMessage()); 
        }
        
    }
    //FINISH
    public void finish(Database.BatchableContext bc) {
        
    } 
    
    public string getJsonPayload1(List<orderItem> ordItems){
        List<String> orderList = new List<String>();
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('inputs');
        gen.writeStartArray();
        for(orderItem ordItem : ordItems){
            orderList.clear();
            orderList.add(ordItem.id);
            gen.writeStartObject();
            gen.writeObjectField('OrderItemsIds',orderList);
            gen.writeEndObject();
        }
        gen.writeEndArray();
        gen.writeEndObject();
        String jsonreq = gen.getAsString();
        system.debug('jsonreq : '+jsonreq);
        return jsonreq;
    }
}