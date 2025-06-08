/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-02-06
 * @description                  : OMS Integration Service
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
 ***************************************************************************************************/
public with sharing class ASDAC_OrderIntegrationService implements ASDAC_IntegrationServices {
  /**
   * ****************************************************************************************************
   * @param stringifiedJSON stringified json
   * @description method to create request
   * @return String
   * ****************************************************************************************************
   */
  public String createRequest(String stringifiedJSON) {
    return null;
  }

  /**
   * ****************************************************************************************************
   * @param metadataRecord integration metadata record
   * @param stringifiedJSON stringified json
   * @description method to do callout
   * @return ASDAC_IntegrationUtility.ResultWrapper
   * ****************************************************************************************************
   */
  public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt metadataRecord, String stringifiedJSON) {
    RequestWrapper req = (RequestWrapper) JSON.deserialize(stringifiedJSON, RequestWrapper.class);
    ASDAC_IntegrationUtility.IntegrationWrapper intWrapper = req.toIntegrationWrapper();
    intWrapper.metadataRecord = metadataRecord;
    HttpResponse res = ASDAC_IntegrationUtility.sendRequest(intWrapper, false).response;
    return new ASDAC_IntegrationUtility.ResultWrapper(res);
  }

  public class RequestWrapper {
    public List<String> params;
    public String body;
    public Boolean isGrocery = false;
    
    public ASDAC_IntegrationUtility.IntegrationWrapper toIntegrationWrapper() {
      ASDAC_IntegrationUtility.IntegrationWrapper intWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
      intWrapper.listOfQueryParameters = (List<Object>) params;
      intWrapper.requestBody = body;
      return intWrapper;
    }
  }
}