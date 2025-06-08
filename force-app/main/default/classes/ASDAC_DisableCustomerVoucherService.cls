/**********************************************************************************
* @author                       : Abhay Patle
* @date                         : 08/03/2023
* @description                  : ASDAC-9270 - Rel B - Geo - GV - CCA UI API integration - Disable Voucher
* @Modify By                    : Niteesh Kumar
**********************************************************************************/

public with Sharing class ASDAC_DisableCustomerVoucherService { 
    public static String orgDomain = Url.getSalesforceBaseUrl().toExternalForm();
    
   
    @AuraEnabled
    public static void toDisableVoucher(String merchantId, String access_token){
        String jsonReq;
        HttpResponse response;
        
        try{
            ASDAC_Loyalty_base_urls__mdt mdtc = ASDAC_Loyalty_base_urls__mdt.getInstance('DisableVoucherURL');
            Merkel_AuthVal__mdt mc = Merkel_AuthVal__mdt.getInstance('getvouchercrm');
            String disableEndpoint = mdtc.Traget_endpoint__c;
             
            String apiAuthorizationHeader = 'Bearer'+' '+access_token;
                     
            //Create body
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject(); 
            gen.writeStringField('merchant_id', merchantId);
            gen.writeEndObject();
            
             jsonReq = gen.getAsString(); 
            
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(disableEndpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('apiauthorization', apiAuthorizationHeader);
            if(orgDomain.contains('sandbox')){
                Blob headerValue = Blob.valueOf(mc.voucherBasicAuthHeader__c);
                String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
                request.setHeader('Authorization', authorizationHeader); 
            }
            request.setBody(jsonReq);
             response =http.send(request);
            if(response.getStatusCode()!=200){
                throw new AuraException(System.Label.ASDAC_GeorgeVoucherDisableError);
            }  
			
        }
        
        catch(exception e){
            System.debug(e.getMessage());
			
			 String logMessage = '';
            logMessage += 'Exception Message:\n'+ e.getMessage() + '\n\n';
           logMessage += 'Request:\n'+ jsonReq + '\n\n';
           logMessage += 'Response:\n'+ response;
            logException(e, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, logMessage);
            ASDAC_Logger.writeLogsToDatabase();   
            
        }
        
    }
     private static void logException(Exception ex, String source, String message) {
        ASDAC_Logger.logException(ex, source, message, 'ASDAC_ManualRefundController');
    }
    
}