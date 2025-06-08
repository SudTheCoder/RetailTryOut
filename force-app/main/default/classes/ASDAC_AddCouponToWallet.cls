/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-05-17
* @Component Type               : Apex Class
* @component Name               : ASDAC_AddCouponToWallet
* @description                  : ASDAC-10298
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-05-23
***************************************************************************************************/
public with sharing class ASDAC_AddCouponToWallet {
    
    /**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-05-15
* @Method Name                  : addCoupon
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-05-23
**********************************************************************************/
    public static ASDAC_GoodWillWalletIdentity.ResponseWrapper addCoupon(Integer decDiscountAmount, String strWalletId, String strVoucherType, String accId,String strReasonCode){
        try{
            //Variable declaration
            ASDAC_Loyalty_Campaign_Mapping__c objCampaignID = new ASDAC_Loyalty_Campaign_Mapping__c();
            String strJSONRequest;
            Boolean voucherGHSEmailDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('EVoucherGHSEmailDisable').ASDAC_LoyaltySwitch__c;
			
            objCampaignID = ASDAC_Loyalty_Campaign_Mapping__c.getInstance(strVoucherType);
            

            strJSONRequest = '{"status":"ACTIVE","state":"UNLOADED","meta":{"key1":"CampaignName:'+objCampaignID.MasterLabel__c+',ReasonCode:'+strReasonCode+'"},"balances":{"available":12},"overrides":{"reward":{"discountAmount":'+decDiscountAmount+'}}}';
            
            String strURL = '/wallet/'+strWalletId+'/campaign/'+objCampaignID.Campaign_Id__c+'/account';
            
            HttpRequest httpRequest = ASDAC_HashTokenGenerator.sendAISRequest(strJSONRequest,'POST',strURL);
            
            Http http = new Http();
            HttpResponse response = http.send(httpRequest);
            if(response.getStatusCode() == 201){
                ASDAC_GoodWillWalletIdentity.ResponseWrapper respWrap = (ASDAC_GoodWillWalletIdentity.ResponseWrapper)JSON.deserialize(response.getBody(), ASDAC_GoodWillWalletIdentity.ResponseWrapper.class);
                if(!Test.isRunningTest() && !voucherGHSEmailDisable){
                    ASDAC_TriggerVoucherEmail.sendVoucherEmail(accId, null, decDiscountAmount, 'GHS');
                }
                return respWrap;
            }
            else{                
                Map<String,Object> result = (Map<String,Object>)json.deserializeUntyped(response.getBody());
                if(result.get('errorMessage')!=null){
                    throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage+' : '+result.get('errorMessage'));
                }else{
                    throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage);
                }  
            }
        }
        
        catch(Exception e){
            System.debug('Error: ' + e.getMessage());
            throw new AuraException(e.getMessage());
        }
        
    }  
}