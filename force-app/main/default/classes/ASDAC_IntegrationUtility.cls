/******************************************************************************
Name: ASDAC_IntegrationUtility
===============================================================================
Req : This Class will be used to do the syncrhonous callouts
===============================================================================
Purpose : This Class will be used to do the callout
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                            DATE         	DETAIL
1.0       Nitish Yadav    		            7 Dec 2022      Initial Development
2.0       Akshay Singh Shekhawat      		17 July 2022    Added setHeaders method
3.0       Vineeth        		            10 July 2022    Added getEndpoint method
******************************************************************************/
public with sharing class ASDAC_IntegrationUtility {
        
	/**************************************************************************
    Purpose    : Method to send a request for a callout                                                        
    Parameters : IntegrationWrapper integrationDetails
    Returns    : HTTPResponse 
    **************************************************************************/ 
    public static HttpResponse sendRequest(IntegrationWrapper integrationDetails) {
		return sendRequest(integrationDetails, true).response;
    }
    
	/**************************************************************************
    Purpose    : Method to send a request for a callout                                                        
    Parameters : IntegrationWrapper integrationDetails
    Returns    : HTTPResponse 
    **************************************************************************/ 
    public static HttpResponseWrapper sendRequest(IntegrationWrapper integrationDetails, Boolean isInsertLog) {
        HttpResponseWrapper resWrap = new HttpResponseWrapper();
        HttpResponse response = new HttpResponse();
        if(integrationDetails.metadataRecord != null) {
            response = calloutService(integrationDetails);
            Log__c log = createLog(integrationDetails, response);
            if(isInsertLog && Log__c.SobjectType.getDescribe().isCreateable()) {
				insert log;                
            }
            resWrap.log = log;
            resWrap.response = response;
        }
        return resWrap;
    }
    
	/**************************************************************************
    Purpose    : Method to send a request for a callout                                                        
    Parameters : IntegrationWrapper integrationDetails
    Returns    : HTTPResponse 
    **************************************************************************/    
    private static HTTPResponse calloutService(IntegrationWrapper integrationDetails) { 
        HttpRequest req = new HttpRequest();
        req.setEndpoint(getEndpoint(integrationDetails));
        req.setMethod(integrationDetails.metadataRecord.MethodType__c);           
        req.setTimeout(Integer.valueOf(integrationDetails.metadataRecord.RequestTimeout__c));
        req = setHeaders(integrationDetails.metadataRecord,req);
        
        if(integrationDetails.metadataRecord.ContentType__c != null){
            req.setHeader('Content-Type', integrationDetails.metadataRecord.ContentType__c); 
        }
        if(integrationDetails.requestBody != null) {
            req.setBody(integrationDetails.requestBody);
            req.setHeader('Accept', 'application/json');
        }
        if(integrationDetails.accessToken != null) {
            req.setHeader('Authorization','Bearer ' + integrationDetails.accessToken);
        }
        if (integrationDetails.requestHeaders != null && !integrationDetails.requestHeaders.isEmpty()) {
            for (String key : integrationDetails.requestHeaders.keySet()) {
                req.setHeader(key, integrationDetails.requestHeaders.get(key));
            }
        }
        
        Http h = new Http();
        HttpResponse response = h.send(req);
        return response;
    }
    
	/**************************************************************************
    Purpose    : Method to set headers for endpoints                                                      
    Parameters : IntegrationWrapper integrationDetails, HttpRequest req
    Returns    : HttpRequest 
    **************************************************************************/    
    private static HttpRequest setHeaders(ASDAC_IntegrationMetadata__mdt metadataRecord, HttpRequest req){
        List<ASDAC_Integration_Headers__mdt> lstIntegrationHeaders = [SELECT Id,MasterLabel,Header_Name__c,Header_Value__c,Integration_Metadata__c 
                                                                      FROM ASDAC_Integration_Headers__mdt 
                                                                      WHERE Integration_Metadata__c =: metadataRecord.Id];
        
        if(lstIntegrationHeaders.size()>0){
            for(ASDAC_Integration_Headers__mdt mtdRec : lstIntegrationHeaders){
                if (metadataRecord.X_Correlation_ID__c == true && mtdRec.Header_Name__c == ASDAC_OMSConstants.X_Correlation_ID_STRING) {
                    String formatDate = DateTime.now().formatGmt(mtdRec.Header_Value__c);
                    req.setHeader(mtdRec.Header_Name__c,formatDate); 
                }
                else {
                    req.setHeader(mtdRec.Header_Name__c,mtdRec.Header_Value__c); 
                }
            }
        }
        return req;
    }
    
	/**************************************************************************
    Purpose    : Method to get Endpoint for a callout
    Parameters : IntegrationWrapper integrationDetails
    Returns    : String 
    **************************************************************************/    
    private static String getEndpoint(IntegrationWrapper integrationDetails) {

        String endpointUrl = String.format(
                ASDAC_OMSConstants.CALLOUT_STRING +
                integrationDetails.metadataRecord.NamedCredential__c +
                integrationDetails.metadataRecord.EndPointURL__c,
                integrationDetails.listOfQueryParameters
            );

        List<String> paramList = new List<String>();
        List<ASDAC_IntegrationQueryParameter__mdt> parameters = [
            SELECT ParameterName__c, ParameterValue__c
            FROM ASDAC_IntegrationQueryParameter__mdt
            WHERE IntegrationMetadata__c = :integrationDetails.metadataRecord.Id
            WITH SECURITY_ENFORCED
        ];
        for (ASDAC_IntegrationQueryParameter__mdt parameter : parameters) {
            paramList.add(parameter.ParameterName__c+'='+parameter.ParameterValue__c);
        }
        
        if(!paramList.isEmpty()){
            if(integrationDetails.listOfQueryParameters == null || integrationDetails.listOfQueryParameters.isEmpty()){
                endpointUrl = endpointUrl + '?' +String.join(paramList, '&');
            }
            else{
                endpointUrl = endpointUrl +String.join(paramList, '&');
            }
            
        }
        
        return endpointUrl;
    }
    
    /**************************************************************************************************************
    * @author       : Sapient: Nitish Yadav
    * @date         : 2022-08-24
    * @description  : This method is used to insert log record
    * @param        : IntegrationWrapper integrationDetails, HttpResponse resp
    * @return       : void
    ***************************************************************************************************************/    
    //Need to implement loging Framework in order make it simplified for all integrations
    public static Log__c createLog(IntegrationWrapper integrationDetails, HttpResponse resp) {
        Log__c log = new Log__c( 
            LogType__c = 'Debug',
            User__c = UserInfo.getUserId()
        ); 
        if(integrationDetails.metadataRecord != null) {
            log.Source__c = integrationDetails.metadataRecord.Source__c;
            log.ExternalSystem__c = integrationDetails.metadataRecord.ExternalSystem__c;
        }
        //Request and Response we are storing only if Status code is not 200
        if(resp.getStatusCode() != 200) {
            log.Message__c = 'Request : ' + integrationDetails.requestBody + '\n Response : ' + resp.getBody();
            if(log.ExternalSystem__c == 'Medallia')
            {
                Map<Integer, ASDAC_HTTPCalloutResponseCode__mdt> responseCodeToResponseMsgMap = new Map<Integer, ASDAC_HTTPCalloutResponseCode__mdt>();
                for(ASDAC_HTTPCalloutResponseCode__mdt responseCodeMetadata:ASDAC_HTTPCalloutResponseCode__mdt.getAll().values())
                {
                  if(!responseCodeToResponseMsgMap.containsKey(Integer.valueOf(responseCodeMetadata.ResponseCode__c)))
                  responseCodeToResponseMsgMap.put(Integer.valueOf(responseCodeMetadata.ResponseCode__c),responseCodeMetadata);
                }
                if(responseCodeToResponseMsgMap.containsKey(resp.getStatusCode())) {
                	log.Message__c = 'Request : ' + integrationDetails.requestBody + '\n Response : ' + resp.getBody() + '\n Description : ' + responseCodeToResponseMsgMap.get(resp.getStatusCode()).ResponseMessage__c;
			        log.LogType__c = 'Exception';
                    log.ExceptionType__c=responseCodeToResponseMsgMap.get(resp.getStatusCode()).MasterLabel;
                }
            }
        }
        return log;
    }   
    
    public class IntegrationWrapper {
        public ASDAC_IntegrationMetadata__mdt metadataRecord;
        public String requestBody;
        public List<Object> listOfQueryParameters;
        public Map<String, String> requestHeaders;
        public String accessToken;
    }
    
    public class ResultWrapper {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strData;
        @AuraEnabled public Log__c log;
        @AuraEnabled public Integer statusCode;
        
        public ResultWrapper(Boolean isSuccess, String strMessage, String strData) {
            this.isSuccess = isSuccess;
            this.strMessage = strMessage; 
            this.strData = strData; 
        }

        public ResultWrapper(HttpResponse res) {
            this.isSuccess = res.getStatusCode() < 300;
            this.statusCode = res.getStatusCode();
            this.strData = res.getBody();
        }
    }
    
    public class HttpResponseWrapper {
        public Log__c log;
        public HttpResponse response;
    }
}