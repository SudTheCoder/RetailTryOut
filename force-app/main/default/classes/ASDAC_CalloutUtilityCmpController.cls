/**************************************************************************************************************
* @author                       : Akshay Singh Shekhawat
* @date                         : 11/11/2022
* @description                  : ASDAC-5351,ASDAC-5064
*************************************************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Akshay Singh Shekhawat       11/11/2022          Initial Class Code
* Akshay Singh Shekhawat       14/11/2022          Updated Class with Interface
* Vineeth Rangamgari           06/02/2022          Updated Class using Callout Service
***************************************************************************************************/
public with sharing class ASDAC_CalloutUtilityCmpController {
    
    /**************************************************************************
    Purpose    : Method to call Service Class doCallout method and return
				 response to LWC component
    Parameters : String mdtName, String stringifiedJSON
    Returns    : String                                               
    **************************************************************************/
    @AuraEnabled 
    public static String getResponseMethod(String mdtName, String stringifiedJSON) {
    	ASDAC_IntegrationUtility.ResultWrapper resultWrap;
        try {
            resultWrap = ASDAC_CalloutService.getResponseMethod(mdtName, stringifiedJSON);
            
        }
        catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, null, 'ASDAC_CalloutUtilityCmpController');
            ASDAC_Logger.writeLogsToDatabase();
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(mdtName, ex.statusCode));
        }
        catch (Exception ex) {
            ASDAC_Logger.logException(ex);
            ASDAC_Logger.writeLogsToDatabase();
            resultWrap = new ASDAC_IntegrationUtility.ResultWrapper(false, ex.getMessage(), '');  
        }  
        return JSON.serialize(resultWrap);
    }
}