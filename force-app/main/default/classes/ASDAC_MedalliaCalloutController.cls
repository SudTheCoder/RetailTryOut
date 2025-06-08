/**************************************************************************************************************
* @author                       : Amey Priolkar
* @date                         : 18/11/2022
* @description                  : ASDAC-3300 CSAT Trigger
*************************************************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description 
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Amey Priolkar                 18-November-2022   Created the class
***************************************************************************************************/
public with sharing class ASDAC_MedalliaCalloutController {

	/**
	* ****************************************************************************************************
	* @description Class exposed to flow which returns Case Id
	* ****************************************************************************************************
	*/
	public class FlowInputs {
		@InvocableVariable public String caseId;
	}

	/**
	* ****************************************************************************************************
	* @param NA
	* @description invoked from Case flow which sets the CSAT flag on Case
	* @return String JSON serialized request body
	* ****************************************************************************************************
	*/
	@InvocableMethod(label='invoke Medallia Callout' description='Medallia Callout is initiated')
	public static void initiateCalloutToMedallia(List<FlowInputs> request) {
        try {
			String caseId = request[0].caseId;
            if(String.isNotBlank(caseId)) {
                calloutToMedallia(caseId);
            }else{
                writeLogsToDatabase('Case Id is blank.');
            }           
        }
        catch(Exception ex) {
			ASDAC_Logger.logException(ex);
            ASDAC_Logger.writeLogsToDatabase();
        }
	}
    
    @future(callout=true)
    public static void calloutToMedallia(String caseId) {
		ASDAC_IntegrationUtility.ResultWrapper medalliaSendCSATResp = (ASDAC_IntegrationUtility.ResultWrapper)JSON.deserialize(ASDAC_CalloutUtilityCmpController.getResponseMethod('SendCSATSurvey', JSON.serialize(new ASDAC_MedalliaCSATSurveySendService.RequestHelperWrapper(caseId))), ASDAC_IntegrationUtility.ResultWrapper.Class);
            if(medalliaSendCSATResp.isSuccess) {
                Update new Case(CSATRequested__c = true, Id = caseId);
            }
    }


	/**
	 * ****************************************************************************************************
	 * @param exceptionMessage exception message
	 * @description future method to write logs to database
	 * ****************************************************************************************************
	 */
	@future
	private static void writeLogsToDatabase(String exceptionMessage) {
		ASDAC_Logger.logException(exceptionMessage, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, 'ASDAC_MedalliaCalloutController');
		ASDAC_Logger.writeLogsToDatabase();
	}
}