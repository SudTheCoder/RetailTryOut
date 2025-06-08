/**********************************************************************************************
@author    		Sapient : Ramdev Chahar
@date      		5 August 2022
@description: 	This Class is used in Trigger framework to bypass the specific trigger for
                perticular execution
**********************************************************************************************/
public class ASDAC_TriggerHandler {
    @testvisible
    private static Set<String> bypassedHandlers = new Set<String>();
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		5 August 2022
	@param			String handlerName
	@return			void
	@description	This method can we used to bypass the specific Trigger for Perticular Execution
	**********************************************************************************************/
    public static void bypass(String handlerName) {
        ASDAC_TriggerHandler.bypassedHandlers.add(handlerName);
    }
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		5 August 2022
	@param			String handlerName
	@return			void
	@description	This method can we used to clear bypass the specific Trigger for Perticular Execution
	**********************************************************************************************/
    public static void clearBypass(String handlerName) {
        ASDAC_TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		5 August 2022
	@param			String handlerName
	@return			Boolean
	@description	This method can we used to check if Trigger is bypassed in Perticular Execution
	**********************************************************************************************/
    public static Boolean isBypassed(String handlerName) {
        return ASDAC_TriggerHandler.bypassedHandlers.contains(handlerName);
    }
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		5 August 2022
	@param			String handlerName
	@return			void
	@description	This method can we used to clear All bypassed Triggers for Perticular Execution
	**********************************************************************************************/
    public static void clearAllBypasses() {
        ASDAC_TriggerHandler.bypassedHandlers.clear();
    }

}