/**********************************************************************************
* @author                       : Vineeth Rangamgari
* @date                         : 2023-06-15
* @description                  : ASDA Rewards Service
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Vineeth Rangamgari            15-Jun-2023        ASDAC-12751 POC
* Sanskriti Vijay               04-Aug-2023        ASDAC-14192
***************************************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Ashwini S           19-Feb-2023        AEGO-580
***************************************************************************************************/
public with sharing class ASDAC_RewardsService {
    public static Integer getResponse(String integrationMetadata, String jsonString, Type typeObj) {
        ASDAC_IntegrationUtility.ResultWrapper result = ASDAC_CalloutService.getResponseMethod(integrationMetadata, jsonString);
       
        if (ASDAC_ErrorHandler.checkForException(integrationMetadata,result.statusCode)) {
            throw new ASDAC_ErrorHandler.CustomCalloutException(result);
        }
        else if (ASDAC_ErrorHandler.checkForEmptyResponse(result.statusCode)) {
            return null;
        } 
        return (result.statusCode);
    }
    /**
   * ****************************************************************************************************
   * @param stringifiedJSON stringified json
   * @description method to create request
   * @return String
   * ****************************************************************************************************
   */
    public static Integer unlinkProfile(String crmId, String integrationMetadata){
    Rewardawrapper requestWrap = new Rewardawrapper();
    requestWrap.crmId = crmId;
    String requestJson = JSON.serialize(requestWrap);
        
    Integer response = (Integer) getResponse(integrationMetadata, requestJson, Integer.class);
    return response; 
    }
    
     public class Rewardawrapper {
        public String crmId;
    }
}