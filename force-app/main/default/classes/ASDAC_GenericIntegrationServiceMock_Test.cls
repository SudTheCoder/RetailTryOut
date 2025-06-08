/**********************************************************************************
 * @author                       : Sanskriti Vijay
 * @date                         : 07-Aug-2023
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Sanskriti Vijay            07-Aug-2023           Mock Class for ASDAC_GenericIntegrationService Test Cases
 ***************************************************************************************************/
public class ASDAC_GenericIntegrationServiceMock_Test implements HttpCalloutMock {

    private String resourceName;
    private Integer statusCode;
    private String body;

  public ASDAC_GenericIntegrationServiceMock_Test(Integer code, String message) {
    statusCode = code;
    body = message;
  }
    
    public HttpResponse respond(HttpRequest req) {
    Integer code = statusCode;
    String content = body;

    if (String.isNotEmpty(resourceName)) {
      content = ASDAC_CommonUtility.getStaticResource(resourceName);
    }

    HttpResponse res = new HttpResponse();
    res.setStatusCode(code);
    res.setBody(content);
    return res;
  }
}