/***********************************************************************************************************
* @author        : Sapient: Sathish Thallapelly
* @date          : 2022-05-20
* @description   : ASDAC_HTTPCalloutServiceMock_Test is the mock class used for single HTTP Callout during testing
**********************************************************************************8*************************/
@isTest
public class ASDAC_HTTPCalloutServiceMock_Test implements HTTPCalloutMock {

    private HTTPResponse response;
    private Integer responseCode;
    private String responseBody;
    private String responseStatus;
    private Blob responseBodyAsBlob;
    private Map<String, String> responseHeaders;

    public ASDAC_HTTPCalloutServiceMock_Test() {
        responseHeaders = new Map<String, String>();
    }

/**************************************************************************************************************
* @author       : Sapient: Sathish Thallapelly
* @date         : 2022-05-20
* @description  : Constructor with response code and response body
***************************************************************************************************************/ 
    public ASDAC_HTTPCalloutServiceMock_Test(Integer responseCode, String responseBody) {
        responseHeaders = new Map<String, String>();
        this.responseCode = responseCode;
        this.responseBody = responseBody;
    }
/**************************************************************************************************************
* @author       : Sapient: Sathish Thallapelly
* @date         : 2022-05-20
* @description  : Getters and Setters
***************************************************************************************************************/  
    public Integer getResponseCode() {
        return responseCode;
    }

    public void setResponseCode(Integer responseCode) {
        this.responseCode = responseCode;
    }

    public String getResponseBody() {
        return responseBody;
    }

    public void setResponseBody(String responseBody) {
        this.responseBody = responseBody;
    }

    public Map<String, String> getResponseHeaders() {
        return responseHeaders;
    }

    public void setResponseHeader(String key, String value) {
        responseHeaders.put(key, value);
    }

    public String getResponseStatus() {
        return responseStatus;
    }

    public void setResponseStatus(String responseStatus) {
        this.responseStatus = responseStatus;
    }

    public Blob getResponseBodyAsBlob() {
        return responseBodyAsBlob;
    }

    public void setResponseBodyAsBlob(Blob responseBodyAsBlob) {
        this.responseBodyAsBlob = responseBodyAsBlob;
    }
  
/**************************************************************************************************************
* @author       : Sapient: Sathish Thallapelly
* @date         : 2022-05-20
* @description  : This method is used to generate and send the mock HTTP Response for the incoming request
* @param        : HTTPRequest request
* @return       : It is returning a response
***************************************************************************************************************/ 
    public HTTPResponse respond(HTTPRequest request) {
        response = new HTTPResponse();
        if(responseCode!=null) {
            response.setStatusCode(responseCode);
        }
        if(responseStatus!=null) {
            response.setStatus(responseStatus);
        }
        if(responseBodyAsBlob!=null) {
            response.setBodyAsBlob(responseBodyAsBlob);
        } else {
            response.setBody(responseBody);
        }
        if(responseHeaders != null) {
            for(String headerKey : responseHeaders.keySet()) {
                response.setHeader(headerKey, responseHeaders.get(headerKey));
            }
        }
        return response;
    }
    
}