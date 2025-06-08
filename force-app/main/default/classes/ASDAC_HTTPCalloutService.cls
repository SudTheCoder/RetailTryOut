/**********************************************************************************
* @author        : Sapient: Dependra Singh
* @date          : 2022-05-27
* @description   : ASDAC_HTTPCalloutService is the service class for performing HTTP Callouts
**********************************************************************************/
public with sharing class ASDAC_HTTPCalloutService {

    ASDAC_HTTPCalloutConfiguration__mdt calloutMetadata;
    String endpointURL;
    String requestMethod;
    String requestBody;
    String requestCertificate;
    String correlationId;
    Blob requestBodyAsBlob;
    Dom.Document requestBodyAsDocument;
    Integer requestTimeout;
    Boolean isCompressedRequest;
    Map<String, String> headerParametersMap;
    static final String TYPE_HEADER_PARAMETERS = 'HEADER_PARAMETERS';
    private static final String STRING_DEBUGTYPE = 'Debug';
    private static final String STRING_EXCEPTIONTYPE = 'Exception';
    HTTPRequest request;
	List<Object> listOfQueryParameters;

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Getters and Setters
***************************************************************************************************************/     
    public String getEndpointURL() {
        return endpointURL;
    }

    public void setEndpointURL(String endpointURL) {
        this.endpointURL = endpointURL;
    }

    public String getRequestMethod() {
        return requestMethod;
    }

    public void setRequestMethod(String requestMethod) {
        this.requestMethod = requestMethod;
    }

    public String getRequestBody() {
        return requestBody;
    }

    public void setRequestBody(String requestBody) {
        this.requestBody = requestBody;
    }

    public Blob getRequestBodyAsBlob() {
        return requestBodyAsBlob;
    }

    public void setRequestBodyAsBlob(Blob requestBodyAsBlob) {
        this.requestBodyAsBlob = requestBodyAsBlob;
    }

    public Dom.Document getRequestBodyAsDocument() {
        return requestBodyAsDocument;
    }

    public void setRequestBodyAsDocument(Dom.Document requestBodyAsDocument) {
        this.requestBodyAsDocument = requestBodyAsDocument;
    }

    public String getRequestCertificate() {
        return requestCertificate;
    }

    public void setRequestCertificate(String requestCertificate) {
        this.requestCertificate = requestCertificate;
    }

    public Integer getRequestTimeout() {
        return requestTimeout;
    }

    public void setRequestTimeout(Integer requestTimeout) {
        this.requestTimeout = requestTimeout;
    }

    public Boolean getIsCompressedRequest() {
        return isCompressedRequest;
    }

    public void setIsCompressedRequest(Boolean isCompressedRequest) {
        this.isCompressedRequest = isCompressedRequest;
    }

    public String getHeaderParameter(String key) {
        return headerParametersMap.get(key);
    }

    public Map<String, String> getHeaderParameters() {
        return headerParametersMap;
    }

    public void setHeaderParameter(String key, String value) {
        if(String.isNotEmpty(key) && String.isNotEmpty(value)) {
            headerParametersMap.put(key, value);
        }
    }

    public void removeHeaderParameter(String key) {
        headerParametersMap.remove(key);
    }
	
	public String getCorrelationId() {
		return correlationId;
	}
	
    //Generating Correlation Id
	public void setCorrelationId() {
		Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		correlationId = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
	}
 
    public ASDAC_HTTPCalloutService() {
        initialize();
    }
    
/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Constructor with Custom Metadata
* @param        : String customMetadataName
* @return       : void
***************************************************************************************************************/ 
    public ASDAC_HTTPCalloutService(String customMetadataName) {
        try {
            calloutMetadata = ASDAC_HTTPCalloutConfiguration__mdt.getInstance(customMetadataName);
        } catch (Exception e) {
            throw new ASDAC_HTTPCalloutFrameworkException(ASDAC_HTTPCalloutFrameworkException.CUSTOM_METADATA_NOT_FOUND);
        }
        initialize();
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : Initialization of class variables
* @param        : null
* @return       : void
***************************************************************************************************************/   
    private void initialize() {
        headerParametersMap = new Map<String, String>();
        if(calloutMetadata != null) {
			endpointURL = String.format('callout:' + calloutMetadata.NamedCredential__c  + calloutMetadata.EndpointURL__c, listOfQueryParameters);
			requestBody = String.isNotBlank(requestBody) ? requestBody : calloutMetadata.Body__c;
            requestMethod = calloutMetadata.Method__c;
            requestTimeout = Integer.valueOf(calloutMetadata.Timeout__c);
            isCompressedRequest = calloutMetadata.IsCompressed__c;
            requestCertificate = calloutMetadata.CertificateName__c;
            setHeaderParameters(calloutMetadata.HeaderParameters__c);
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : This method is used to set Header parameters from Custom Metadata
* @param        : String parameterType, String parameterInfo
* @return       : void
***************************************************************************************************************/    
    private void setHeaderParameters(String parameterInfo) {
        if(String.isNotEmpty(parameterInfo)) {
            Map<String, String> parametersMap = new Map<String, String>();
            List<String> parameters = parameterInfo.split('\n');
            for(String urlParam : parameters) {
                List<String> keyValuePair = urlParam.trim().split(':');   
                if(!keyValuePair.isEmpty() && keyValuePair.size() == 2 && String.isNotEmpty(keyValuePair[0]) && String.isNotEmpty(keyValuePair[1])) {
					parametersMap.put(keyValuePair[0], keyValuePair[1]);
                }
            }
			headerParametersMap.putAll(parametersMap);
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : This method is used to set Header parameters using headerParametersMap
* @param        : null
* @return       : void
***************************************************************************************************************/   
    private void addHeaderParameters() {
        for(String key : headerParametersMap.keySet()) {
            request.setHeader(key, headerParametersMap.get(key));
        }
		setCorrelationId();
		request.setHeader('CorrelationId', getCorrelationId());
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : This method is used to form HTTP Request
* @param        : null
* @return       : void
***************************************************************************************************************/ 
    public void formHTTPRequest() {
        request = new HTTPRequest();
        addHeaderParameters();
        if(String.isNotEmpty(endpointURL)) {
            request.setEndpoint(endpointURL);
        }
        if(String.isNotEmpty(requestMethod)) {
            request.setMethod(requestMethod);
        }
        if(String.isNotEmpty(requestBody)) {
            request.setBody(requestBody);
        } else if((requestBodyAsBlob != null) &&  String.isNotEmpty(requestBodyAsBlob.toString())) {
            request.setBodyAsBlob(requestBodyAsBlob);
        } else if((requestBodyAsDocument != null) && String.isNotEmpty(requestBodyAsDocument.toXmlString())) {
            request.setBodyDocument(requestBodyAsDocument);
        }
        if(requestTimeout!=null) {
            request.setTimeout(requestTimeout);
        }
        if(String.isNotEmpty(requestCertificate)) {
            request.setClientCertificateName(requestCertificate);
        }
        if(isCompressedRequest!=null) {
            request.setCompressed(isCompressedRequest);
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : This method forms and returns the HTTP Request without sending (for debugging purposes
* @param        : null
* @return       : It returns a http request
***************************************************************************************************************/  
    public HTTPRequest getRequest() {
        formHTTPRequest();
        return request;
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : This method is used to send HTTP Request and return the response
* @param        : null
* @return       : It returns a http request
***************************************************************************************************************/  
    public HTTPResponse sendRequest() {
        formHTTPRequest();
        Http http = new Http();
        return createLog(http.send(request));
    }

/**************************************************************************************************************
* @author       : Sapient: Dependra Singh
* @date         : 2022-05-27
* @description  : This method is used to send HTTP Request received in parameter and return the response
* @param        : HTTPRequest request
* @return       : It returns a http request
***************************************************************************************************************/
    public HTTPResponse sendRequest(HTTPRequest request) {
        Http http = new Http();
        return createLog(http.send(request));
    }
    
/**************************************************************************************************************
* @author       : Sapient: Nitish Yadav
* @date         : 2022-08-24
* @description  : This method is used to insert log record
* @param        : HttpResponse resp
* @return       : It returns an Http Response
***************************************************************************************************************/    
    public HttpResponse createLog(HttpResponse resp) {
        Log__c log = new Log__c(
            LogType__c = STRING_DEBUGTYPE,
            User__c = UserInfo.getUserId(),
            Correlation_Id__c = correlationId
        ); 
        if(calloutMetadata != null) {
            log.Source__c = calloutMetadata.Source__c;
            log.ExternalSystem__c = calloutMetadata.ExternalSystem__c;
        }
        if(resp.getStatusCode() != 200) {
            log.Message__c = 'Request : ' + JSON.serialize(requestBody) + '\n Response : ' + resp.getBody();
        }
        if(Log__c.SobjectType.getDescribe().isCreateable()) { 
            insert log;
        }
        return resp;
    }
}