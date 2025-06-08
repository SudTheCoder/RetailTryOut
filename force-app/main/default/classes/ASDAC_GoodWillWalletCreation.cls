/**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 16/05/2023
* @description                  : ASDAC_7971 Rel C - GHS - GV - Integrate CCA UI with API for issuing single goodwill vouchers (with / without wallet)

**********************************************************************************/

public with sharing class ASDAC_GoodWillWalletCreation {
    
    public static ASDAC_GoodWillWalletIdentity.ResponseWrapper createWallet(String crmId, decimal discountAmount,String accId, String strReasonCode,String strVoucherType ){
        
        try{
            //metadata for retriving CampaignId
            
            ASDAC_Loyalty_Campaign_Mapping__c objCampaginID = ASDAC_Loyalty_Campaign_Mapping__c.getInstance(strVoucherType);
            String campaignId = objCampaginID.Campaign_Id__c;
            String strLabel = objCampaginID.MasterLabel__c;
            
            
            Boolean voucherGHSEmailDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('EVoucherGHSEmailDisable').ASDAC_LoyaltySwitch__c;
            
            //JSON Request
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeFieldName('identities');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('type', 'CRM_ID');
            gen.writeStringField('value', crmId);
            gen.writeStringField('status', 'ACTIVE');
            gen.writeEndObject();
            gen.writeEndArray();
            gen.writeFieldName('accounts');
            gen.writeStartObject();
            gen.writeFieldName('campaign');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('campaignId', campaignId);
            gen.writeStringField('status', 'ACTIVE');
            gen.writeStringField('state', 'UNLOADED');
            gen.writeFieldName('meta');
            gen.writeStartObject();
            gen.writeStringField('key1', 'CampaignName:'+strLabel+',ReasonCode:'+strReasonCode);
            gen.writeEndObject();
            gen.writeFieldName('overrides');
            gen.writeStartObject();
            gen.writeFieldName('offer');
            gen.writeStartObject();
            gen.writeFieldName('reward');
            gen.writeStartObject();
            gen.writeNumberField('discountAmount', discountAmount);
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject();
            gen.writeEndObject(); // End of the campaign object
            gen.writeEndArray();
            gen.writeEndObject(); // End of the accounts object
            gen.writeStringField('type', 'CONSUMER');
            gen.writeStringField('status', 'ACTIVE');
            gen.writeStringField('state', 'NONREWARDS');
            gen.writeStringField('friendlyName', 'Asda Loyalty Wallet');
            gen.writeEndObject(); // End of the root object
            String jsonReqBody = gen.getAsString();
            
            HttpRequest request = ASDAC_HashTokenGenerator.sendAISRequest(jsonReqBody,'POST','/wallet');
            
            Http http = new Http();
            
            HttpResponse response = http.send(request);
            Integer statusCode = response.getStatusCode();
            
            if(statusCode == 201){
                ASDAC_GoodWillWalletIdentity.ResponseWrapper respWrap = (ASDAC_GoodWillWalletIdentity.ResponseWrapper)JSON.deserialize(response.getBody(), ASDAC_GoodWillWalletIdentity.ResponseWrapper.class);
                respWrap.accountId = respWrap.accounts.campaign.results[0].accountId;
                if(!Test.isRunningTest() && !voucherGHSEmailDisable){
                    ASDAC_TriggerVoucherEmail.sendVoucherEmail(accId, null, discountAmount, 'GHS');
                }
                return respWrap;
            }else if(statusCode == 207){
                Map<String,Object> result = (Map<String,Object>)json.deserializeUntyped(response.getBody());
                Map<String,Object> campaign = (Map<String,Object>)result.get('accounts');
                Map<String,Object> status = (Map<String,Object>)campaign.get('campaign');
                Map<String,Object> results = (Map<String,Object>)status.get('failed');
                List<object> errormsg = (List<object>)results.get('results');
                Map<String,Object> msg = (Map<String,Object>)errormsg[0];
                throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage+':'+msg.get('errorMessage'));
            }	
            else{
                Map<String,Object> result = (Map<String,Object>)json.deserializeUntyped(response.getBody());
                if(result.get('errorMessage')!=null){
                    throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage+' : '+result.get('errorMessage'));
                }else{
                    throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage);
                }  
            }
        } catch(Exception e){
            System.debug('GoodwillWallet Creation Error: ' + e.getMessage());
            ASDAC_Logger.logException(e, ASDAC_GlobalConstants.STRING_LOYALTY, 'Wallet Creation issue', 'ASDAC_GoodWillWalletCreation');
            ASDAC_Logger.writeLogsToDatabase();
            throw new AuraException(e.getMessage());
        }
    }
}