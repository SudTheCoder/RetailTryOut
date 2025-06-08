/**********************************************************************************
* @author                       : Abhay Patle
* @date                         : 23/02/2023
* @description                  : ASDAC-6277 - Rel B - Geo - GV - CCA UI API integration - View Customer's Voucher History
* @Modify BY                    : Niteesh Kumar 
**********************************************************************************/
public with sharing class ASDAC_AuthorizeSFCCForVoucher {
    //callout demadware to get access token
    @AuraEnabled(cacheable=true)
    public static string getMerkelAuthToken(){
        String accesstoken;
        try{
            Boolean voucherIssueDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('EVoucherDisable').ASDAC_LoyaltySwitch__c;
            if(voucherIssueDisable==false){

                Merkel_AuthVal__mdt merkelAuth = Merkel_AuthVal__mdt.getInstance('getvouchercrm'); 
				Blob headerValue = Blob.valueOf(merkelAuth.tokenbasicAuthHeader__c);
				String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
                String tokenAuthURL = merkelAuth.tokenAuthURL__c; 
                String payload = 'grant_type='+EncodingUtil.urlEncode('client_credentials','UTF-8');
                Http voucherAuthHttp = new Http();
                HttpRequest geoVoucherAuthRequest = new HttpRequest();
                geoVoucherAuthRequest.setEndpoint(tokenAuthURL);
                geoVoucherAuthRequest.setMethod('POST');
                geoVoucherAuthRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                geoVoucherAuthRequest.setHeader('Authorization', authorizationHeader);
                geoVoucherAuthRequest.setBody(payload);
                HttpResponse geoVoucherAuthResponse = voucherAuthHttp.send(geoVoucherAuthRequest);
                Map<String,Object> result = (Map<String,Object>)json.deserializeUntyped(geoVoucherAuthResponse.getBody());
                accesstoken = (String)result.get('access_token');              
            }
            
        }catch(Exception e){
            system.debug('Error '+e.getMessage());
        }
        return accesstoken;
    }
}