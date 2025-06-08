/**********************************************************************************************************************
* @author        : Sapient: Sathish Thallapelly
* @date          : 2022-05-20
* @description   : ASDAC_HTTPCalloutServiceMultiMock_Test is the mock class for multiple HTTP Callouts during testing
**********************************************************************************8************************************/
@isTest
public class ASDAC_HTTPCalloutServiceMultiMock_Test implements HTTPCalloutMock {
    
    Map<String, ASDAC_HTTPCalloutServiceMock_Test> calloutMocks;

/**************************************************************************************************************
* @author       : Sapient: Sathish Thallapelly
* @date         : 2022-05-20
* @description  : Constructor initializing the class variables
***************************************************************************************************************/ 
    public ASDAC_HTTPCalloutServiceMultiMock_Test() {
        calloutMocks = new Map<String, ASDAC_HTTPCalloutServiceMock_Test>();
    }
    
/**************************************************************************************************************
* @author       : Sapient: Sathish Thallapelly
* @date         : 2022-05-20
* @description  : Constructor initializing the class variables (from user input if available)
***************************************************************************************************************/ 
    public ASDAC_HTTPCalloutServiceMultiMock_Test(Map<String, ASDAC_HTTPCalloutServiceMock_Test> calloutMocks) {
        this.calloutMocks = calloutMocks;
        if(this.calloutMocks == null) {
            calloutMocks = new Map<String, ASDAC_HTTPCalloutServiceMock_Test>();
        }
    }

/**************************************************************************************************************
* @author       : Sapient: Sathish Thallapelly
* @date         : 2022-05-20
* @description  : Adding a callout mock class instance to (URL - Mock) map
* @param        : String endpoint, ASDAC_HTTPCalloutServiceMock_Test calloutMock
* @return       : put method
***************************************************************************************************************/ 
    public void addCalloutMock(String endpoint, ASDAC_HTTPCalloutServiceMock_Test calloutMock) {
        calloutMocks.put(endpoint, calloutMock);
    }

/**************************************************************************************************************
* @author       : Sapient: Sathish Thallapelly
* @date         : 2022-05-20
* @description  : This method is used to generate and send a mock HTTP response for the incoming request
*                 It also throws a custom exception in case the mock is not found for the input request URL
* @param        : HTTPRequest request
* @return       : It is returning a response or throwing exception
***************************************************************************************************************/ 
    public HTTPResponse respond(HTTPRequest request) {
        ASDAC_HTTPCalloutServiceMock_Test calloutMock = calloutMocks.get(request.getEndpoint());
        if(calloutMock != null) {
            return calloutMock.respond(request);
        } else {
            throw new ASDAC_HTTPCalloutFrameworkException(ASDAC_HTTPCalloutFrameworkException.MOCK_NOT_FOUND);
        }
    }
}