public with sharing class ASDAC_RetrieveOrderDetailsService implements ASDAC_IntegrationServices {
    
    public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {
        ASDAC_IntegrationUtility.IntegrationWrapper initWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
        initWrapper.metadataRecord = integrationMdt;
        initWrapper.requestBody = createRequest(stringifiedJSON);
        
        RequestHelperWrapper requestHelperWrap = (RequestHelperWrapper)JSON.deserialize(stringifiedJSON, RequestHelperWrapper.class);
        List<StaticResource> lstsr = new List<StaticResource>();
        
        if(String.isNotBlank(requestHelperWrap.recordId)){
            lstsr = [SELECT Id, Body FROM StaticResource WHERE Name =: requestHelperWrap.recordId.replace('-', '_') LIMIT 1];
        }
        
        if(lstsr.size()>0){
            String body = lstsr[0].Body.toString();
            // Need to improve Error Result Logic for different Interfaces
            return new ASDAC_IntegrationUtility.ResultWrapper(true, '', body);
        }
        else{
            // Need to improve Error Result Logic for different Interfaces
            return new ASDAC_IntegrationUtility.ResultWrapper(false, 'No Order Found', '');
        }
        
    }
    
    public static String createRequest(String stringifiedJSON){
        //Need to have Specific Case to use this logic section
        String requestKey = '';
        RequestHelperWrapper requestHelperWrap = (RequestHelperWrapper)JSON.deserialize(stringifiedJSON, RequestHelperWrapper.class);
        if(requestHelperWrap.sObjectName == 'Case') {
            requestKey = [SELECT Id, OrderId__c, Account.ExternalId__c 
                          FROM Case 
                          WHERE Id =: requestHelperWrap.recordId WITH SECURITY_ENFORCED LIMIT 1].OrderId__c;  
        }
        else {
            requestKey = requestHelperWrap.recordId;
        }
        return JSON.serialize(new RequestWrapper(requestKey, 'OrderId', '', false));
    }
    
    public class RequestHelperWrapper{
        public String recordId;
        public String sObjectName;
    }
    
    /*******************************************************************************************************
    * @param NA
    * @param NA
    * @description Request Wrapper class for Stub Demops
    * @return NA
    * *****************************************************************************************************/ 
    public class RequestWrapper {
        public String key;
        public String type;
        public String src;
        public Boolean disabled;
        public RequestWrapper(String key, String type, String src, Boolean disabled) {
			this.key = key;
			this.type = type;
			this.src = src;
			this.disabled = disabled;            
        } 
    }
}