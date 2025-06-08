/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2022-11-29
* @description                  : ASDAC-5969 - George - GV - CCA UI integration with APIs for issuing single vouchers
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                29-Nov-2022      Created the class
***************************************************************************************************/

public with sharing class ASDAC_GetVoucherCode {
    public static String orgDomain = Url.getSalesforceBaseUrl().toExternalForm();
    //voucher codencall from Component     
    @AuraEnabled(Cacheable=true)
    public static ASDAC_GoodWillWalletIdentity.ResponseWrapper getGeorgeVoucherCode(Goodwill__c gw){
        Boolean voucherIssueDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('EVoucherDisable').ASDAC_LoyaltySwitch__c;
        if(voucherIssueDisable==false){
            try{
                String accesstoken = ASDAC_AuthorizeSFCCForVoucher.getMerkelAuthToken();
                Boolean voucherEmailDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('EVoucherEmailDisable').ASDAC_LoyaltySwitch__c;//Refactor
                Merkel_AuthVal__mdt merkelApiDetail = Merkel_AuthVal__mdt.getInstance('getvouchercrm');
                Http voucherCodehttp = new Http();
                HttpRequest getVoucherRequest = new HttpRequest();
                
                String authorizationHeader2 = merkelApiDetail.voucherBasicAuthHeader__c;
                String jsonbody = createRequestBody(gw); 
                String apiAuthorizationHeader = 'Bearer' + ' ' + accesstoken;
                getVoucherRequest.setEndpoint(merkelApiDetail.voucherEndPointURL__c);
                getVoucherRequest.setMethod('POST');
                getVoucherRequest.setHeader('Content-Type', 'application/json');
                getVoucherRequest.setHeader('APIAuthorization', apiAuthorizationHeader);
                if(orgDomain.contains('sandbox')){
                    Blob headerValue = Blob.valueOf(authorizationHeader2);
                    String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
                    getVoucherRequest.setHeader('Authorization', authorizationHeader); 
                }  
                getVoucherRequest.setBody(jsonbody);
                HttpResponse getVoucherResponse = voucherCodehttp.send(getVoucherRequest);
                if(getVoucherResponse.getStatusCode() ==200){
                    ASDAC_GoodWillWalletIdentity.ResponseWrapper respWrap = (ASDAC_GoodWillWalletIdentity.ResponseWrapper)JSON.deserialize(getVoucherResponse.getBody(), ASDAC_GoodWillWalletIdentity.ResponseWrapper.class);
                    gw.Voucher_Code__c = respWrap.gift_certificate_code;
                    
                    if(!test.isRunningTest() && voucherEmailDisable==false){//Refactor
                        ASDAC_TriggerVoucherEmail.sendVoucherEmail(gw.AccountId__c,gw.Voucher_Code__c,gw.VoucherAmount__c,'george');//Refactor
                    }
                    return respWrap;
                }else {
                    Map<String,Object> result = (Map<String,Object>)json.deserializeUntyped(getVoucherResponse.getBody());
                    Map<String,Object> fault = (Map<String,Object>)result.get('fault');
                   sendErrorMessage(fault);
                }
                
            }catch(Exception e){
                system.debug('Error '+e.getMessage());
                throw new AuraException(e.getMessage());
            }
        }
        return null;
    }
    //End
    
    /**
* ****************************************************************************************************
* @description method to create payload for httpcallout to get vouchet code
* @return  Json body as string format
* ****************************************************************************************************
*/
    public static String createRequestBody(Goodwill__c gw){
        Account acc = [Select Id,Name,Loginid__c,PersonContactId from Account where id = :gw.AccountId__c  WITH SECURITY_ENFORCED];
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('_v', '22.10');
        gen.writeFieldName('amount');  
        gen.writeStartObject();
        gen.writeStringField('currency_mnemonic', 'GBP');
        gen.writeNumberField('value', gw.VoucherAmount__c);
        gen.writeEndObject();
        gen.writeStringField('description', gw.ReasonCode__c);
        gen.writeStringField('recipient_email', gw.Email__c);
        gen.writeStringField('status', 'issued');
        gen.writeStringField('c_crm_id', acc.PersonContactId);
        String jsonreq = gen.getAsString();
        return jsonreq;
    }
    
    //Method to Disply fault Message on UI
    public static void sendErrorMessage( Map<String,Object> fault){
        if(fault!=null){
            throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage+' : '+fault.get('message')); 
        }else{
            throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage); 
        }
    }
}