/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-02-14
* @description                  : ASDAC-4148 - George - GV - Integrate SFSC - SFMC - New Voucher Issued Email
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                14-Feb-2022      Created the class
***************************************************************************************************/
public with sharing class  ASDAC_TriggerVoucherEmail  {
    
    /******************************************************************************************************
* @param : Goodwill Voucher Id
* @description : Send a mail to customer about Issued goodwill voucher.
* @return None
* ****************************************************************************************************
*/
        public static void sendVoucherEmail(Id accountId, String vcode, Decimal vamount, String vtype){
        try{
            String  guid = ASDAC_SFMCEmailCallout.generateString(7);
            ASDAC_LoyaltySFMCAuth__mdt authdetail = ASDAC_LoyaltySFMCAuth__mdt.getInstance('GeoAuthDetail');
            String endpoint = authdetail.triggerURL__c+guid;
            String body = jsonbody(accountId,vcode,vamount, vtype);
            Http voucherhttp = new Http();
            HttpRequest demandwareVoucherRequest = new HttpRequest();
            demandwareVoucherRequest.setEndpoint(endpoint);
            demandwareVoucherRequest.setMethod('POST');
            demandwareVoucherRequest.setBody(body);
            demandwareVoucherRequest.setHeader('Content-Type', 'application/json');
            HttpResponse demandwareVoucherResponse = voucherhttp.send(demandwareVoucherRequest);
                        if(demandwareVoucherResponse.getStatusCode()!=ASDAC_GlobalConstants.VOUCHERE_SUCCESS_CODE){
                                throw new AuraException(System.Label.ASDAC_IssueEVoucherEmailNotificationExceptionMessage);
            }
        }catch(Exception e){
            system.debug('Error: '+e.getMessage());  
            throw new AuraException(e.getMessage());
        }
    }
    
    /******************************************************************************************************
* @param : goodwill record, custom metadata record.
* @description : Create json payload for voucher issued mail
* @return json formatted body
* ****************************************************************************************************
*/
    public static String jsonbody(Id accountId, String vcode, Decimal vamount, String vtype){
        Account acc = [Select Id,Name,Loginid__c,PersonContactId,FirstName from Account where id = :accountId WITH SECURITY_ENFORCED];
        ASDAC_LoyaltySFMCAuth__mdt authdetail;
        if(vtype == 'george'){
            authdetail = ASDAC_LoyaltySFMCAuth__mdt.getInstance('BaseAuthDetail'); 
        }else if(vtype == 'GHS'){
            authdetail = ASDAC_LoyaltySFMCAuth__mdt.getInstance('GHSAuthDetail');
        }
        String firstName = acc.FirstName!=null ? acc.FirstName:'';
        JSONGenerator gen = json.createGenerator(true);
        gen.writeStartObject();
       gen.writeStringField('definitionKey',authdetail.definitionKey__c);
        gen.writeFieldName('recipient');
        gen.writeStartObject();
        gen.writeStringField('contactKey',acc.PersonContactId);
        gen.writeStringField('to',acc.Loginid__c );
        gen.writeFieldName('attributes');
        gen.writeStartObject();
        gen.writeStringField('FirstName', firstName);
        if(vtype == 'george'){
            gen.writeStringField('EVoucherCode', vcode);
            gen.writeNumberField('EVoucherValue', vamount);
        }else if(vtype == 'GHS'){
            gen.writeStringField('EmailAddress',acc.Loginid__c);
            gen.writeNumberField('voucherAmount', vamount/100);
            gen.writeStringField('promotionType', 'ORDER_AMOUNT_OFF');
        }
        gen.writeEndObject();gen.writeEndObject();gen.writeEndObject();
        String body = gen.getAsString();
                return body;
    }
}