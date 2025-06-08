/**********************************************************************************
 * @author                       : Vineeth Rangamgari
 * @date                         : 2022-02-06
 * @description                  : Callout Service
 **********************************************************************************/
/*
 * Modification Log:
 *---------------------------------------------------------------------------------------------------
 * Developer                     Date               Description
 *---------------------------------------------------------------------------------------------------
 *---------------------------------------------------------------------------------------------------
 * Vineeth Rangamgari            06-Feb-2022        OMS Integration re-design
 ***************************************************************************************************/
public with sharing class ASDAC_CalloutService {
  /**
   * ****************************************************************************************************
   * @param mdtName integration metadata record
   * @param stringifiedJSON stringified json for creating request
   * @description method to get response after callout
   * @return ASDAC_IntegrationUtility.ResultWrapper
   * ****************************************************************************************************
   */
  public static ASDAC_IntegrationUtility.ResultWrapper getResponseMethod(String mdtName, String stringifiedJSON) {
    ASDAC_IntegrationMetadata__mdt metadataRecord = ASDAC_IntegrationMetadata__mdt.getInstance(mdtName);
    Type serviceName = Type.forName(metadataRecord.ServiceName__c);
    ASDAC_IntegrationServices integrationServices = (ASDAC_IntegrationServices) serviceName.newInstance();
    ASDAC_IntegrationUtility.ResultWrapper resultWrap = integrationServices.doCallout(metadataRecord, stringifiedJSON);
    return resultWrap;
  }


}