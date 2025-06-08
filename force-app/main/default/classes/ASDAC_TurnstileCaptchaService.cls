/**
 * @description       : service class for cloudflare turnstile
 * @author            : Arjun Singh
 * @group             : 
 * @last modified on  : 30-06-2023
 * @last modified by  : Arjun Singh
**/
public with sharing class ASDAC_TurnstileCaptchaService implements ASDAC_IntegrationServices {

    /**
    * @description 
    * @author Arjun Singh | 30-06-2023 
    * @return List<String> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<String> fetchBaseURL() {
        List<String> allowedURLs = new List<String>();

        allowedURLs.add(URL.getOrgDomainUrl().toExternalForm());
        allowedURLs.add(URL.getSalesforceBaseUrl().toExternalForm());
        allowedURLs.add(URL.getOrgDomainUrl().toExternalForm().replace('.my.salesforce.com', '.lightning.force.com'));
        allowedURLs.add(URL.getOrgDomainUrl().toExternalForm().replace('.my.salesforce.com', '--c.visualforce.com'));

        return allowedURLs;
    }
	
    @AuraEnabled(cacheable=true)
    public static ASDAC_BotProtectionCloudflareCaptcha__mdt getCaptchaSettings() {
        ASDAC_BotProtectionCloudflareCaptcha__mdt metaRecord = null;
        try {
            metaRecord = [SELECT Service_Enabled__c, Site_key__c FROM ASDAC_BotProtectionCloudflareCaptcha__mdt WITH SECURITY_ENFORCED Limit 1];
        } catch(Exception ex) {
            ASDAC_Logger.logException(ex);
        }
        return metaRecord;
    }

    /**
    * @description 
    * @author Arjun Singh | 30-06-2023 
    * @param stringifiedJSON 
    * @return String 
    **/
    public String createRequest(String token) {
        TurnstileVerifyRequestWrapper reqBody = new TurnstileVerifyRequestWrapper();
        reqBody.response = token;
        return JSON.serialize(reqBody);
    }

    
    // This inner class is used to encapsulate the parameters passed from the Flow
    public class Request {
        @InvocableVariable(required=true)
        public String token;
    }

    // This inner class is used to encapsulate the response back to the Flow
    public class Response {
        @InvocableVariable
        public Boolean isValid;
        @InvocableVariable
        public String errors;
        
    }
    
    // Method to be called from a Flow
    @InvocableMethod(label='Validate Captcha' description='Validates a CAPTCHA token')
    public static List<Response> validateCaptcha(List<Request> requests) {
        Boolean isValid = false;
        String errors = '';
        // Create a list to hold the response
        List<Response> responses = new List<Response>();
        if (String.isNotBlank(requests[0].token)) {
            DetailsWrapper requestBody = new DetailsWrapper();
            requestBody.token = requests[0].token;
            ASDAC_IntegrationUtility.ResultWrapper captchaResp = (ASDAC_IntegrationUtility.ResultWrapper)JSON.deserialize(ASDAC_CalloutUtilityCmpController.getResponseMethod('TurnstileCaptchaVerify', JSON.serialize(requestBody)), ASDAC_IntegrationUtility.ResultWrapper.Class);
            if(captchaResp.isSuccess) {
                isValid = true;
            } else {                
                // Deserialize the strData field to another Map
                Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(captchaResp.strData);
                List<Object> errorCodesObj = (List<Object>) dataMap.get('error-codes');            
                for (Object obj : errorCodesObj) {
                    errors = errors + (String) obj;
                }
            }
        }
        // Create a new response object and set the validity result
        Response res = new Response();
        res.isValid = isValid;
        res.errors = errors;
        // Add the response to the list
        responses.add(res);
        // Return the list of responses
        return responses;
    }
	/**
     * Purpose    : Method to perform callout
     * Parameters : ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON
     * Returns    : ASDAC_IntegrationUtility.ResultWrapper
     **/
    public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {
        DetailsWrapper detailsWrap = (DetailsWrapper)JSON.deserialize(stringifiedJSON, DetailsWrapper.class);
        ASDAC_IntegrationUtility.ResultWrapper resultWrap;

        if (String.isNotEmpty(detailsWrap.token)) {
            ASDAC_IntegrationUtility.IntegrationWrapper initWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
            initWrapper.metadataRecord = integrationMdt;
            initWrapper.requestBody = createRequest(detailsWrap.token);
            HttpResponse resp = ASDAC_IntegrationUtility.sendRequest(initWrapper);
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(resp.getBody());

            if (result.containsKey('success') && (Boolean) result.get('success')) {
                resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(true, '', JSON.serialize(result));
            } else {
                resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(false, '', JSON.serialize(result));
            }
        } else {
            resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(false, 'No token found to verify', '');
        }

        return resultWrap;
    }

   /**
     * Purpose : DetailsWrapper class needed to create the request body
     **/
    public Class DetailsWrapper {
        public String token;
    }

    /**
     * Purpose : Token Wrapper for token request
     **/
    public class TurnstileVerifyRequestWrapper {
        public final String secret = '{!$Credential.password}';
        public String response = '';
        public String remoteip = '';
    }
}