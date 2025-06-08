/**********************************************************************************
* @author                       : Sanskriti Vijay
* @date                         : 04/08/2023
* @description                  : ASDA Rewards Controller
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Sanskriti Vijay              04-Aug-2023        ASDAC-14192
***************************************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date               Description
*---------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------
* Ashwini S             19-Feb-2025        AEGO-580
***************************************************************************************************/
 
public class ASDAC_RewardsController {
   private final static String ASDA_REWARDS_ENDPOINT_MDT = 'ASDA_Rewards_Delete_CRM';
    @AuraEnabled
    public static Integer unlinkProfile(String crmId) {
        String integrationMetadata = ASDA_REWARDS_ENDPOINT_MDT;
        try{
            return ASDAC_RewardsService.unlinkProfile(crmId, integrationMetadata);
            
        }catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_ASDA_REWARDS);
            throw new AuraException(ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode));
        } catch (Exception ex) {
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE);
            throw ex;
        }
    } 

    /**
* ****************************************************************************************************
* @param ex Exception object
* @param source Exception source
* @description method to log Exception
* ****************************************************************************************************
*/
     private static void logException(Exception ex, String source) {
        ASDAC_Logger.logException(ex, source, null, 'ASDAC_RewardsController');
    } 
}