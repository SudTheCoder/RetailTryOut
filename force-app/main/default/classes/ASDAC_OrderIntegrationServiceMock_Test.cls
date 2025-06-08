/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-02-06
 * @description                  : OMS - Integration Service Mock
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
 ***************************************************************************************************/
@IsTest
public with sharing class ASDAC_OrderIntegrationServiceMock_Test implements HttpCalloutMock {
  private String resourceName;
  private Integer statusCode;
  private String body;

  public ASDAC_OrderIntegrationServiceMock_Test(String name) {
    statusCode = 200;
    resourceName = name;
  }

  public ASDAC_OrderIntegrationServiceMock_Test(Integer code, String message) {
    statusCode = code;
    body = message;
  }

  public HttpResponse respond(HttpRequest req) {
    Integer code = statusCode;
    String content = body;

    if (req.getEndpoint().contains('callout:OMS_Auth')) {
      code = 200;
      content = ASDAC_CommonUtility.getStaticResource('OmsAuthMock');
    } else if (String.isNotEmpty(resourceName)) {
      content = ASDAC_CommonUtility.getStaticResource(resourceName);
    }

    HttpResponse res = new HttpResponse();
    res.setStatusCode(code);
    res.setBody(content);
    return res;
  }
}