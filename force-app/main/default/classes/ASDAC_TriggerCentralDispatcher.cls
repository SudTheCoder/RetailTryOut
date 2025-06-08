/**********************************************************************************************
@author    		Sapient : Dependra Singh
@date      		11 May 2022
@description: 	This Class is invoked from the trigger and used to dispatch execution to the handler
				methods depending on the event
@group   		TriggerDispatcher,  Updated with details of how to switch triggers on or off
**********************************************************************************************/
public with sharing class ASDAC_TriggerCentralDispatcher {
    private static final String CLASS_NAME = 'ASDAC_TriggerCentralDispatcher';
	private static final String DEBUG = '[' + CLASS_NAME + '] ';
    public static ASDAC_TriggerHandlerBase activefunction = null;
    /**********************************************************************************************
	@author      	Sapient : Dependra Singh
	@date      		11 May 2022
	@param			ASDAC_TriggerHandlerObj inputParam
	@return			void
	@description	This method is invoked by the code directly from any object triggers. It
	determines the appropriate handler class to fire and runs that so long as
	the custom setting for the user is switched on
	**********************************************************************************************/
    public static void mainEntry(ASDAC_TriggerHandlerObj inputParam){
        //Set up some default variables for this method
        boolean triggerEnabled = true;
        string triggerHandlerName = ASDAC_GlobalConstants.PREFIX + inputParam.triggerObject + ASDAC_GlobalConstants.HANDLERSUFFIX;
        string  triggerFieldName = inputParam.triggerObject + ASDAC_GlobalConstants.CUSTSETFIELDSUFFIX;
        //Retrive the custom setting information 
        ASDAC_DisableAutomation__c automationSetting = ASDAC_DisableAutomation__c.getInstance(UserInfo.getUserId());
        Map<String, Object> custSettingsFields = automationSetting.getPopulatedFieldsAsMap();
        //Identify if the trigger is running for this object
        System.debug('custSettingsFields'+custSettingsFields);
        System.debug('triggerFieldName'+triggerFieldName);
        if(custSettingsFields.containsKey(triggerFieldName)){
            boolean triggerDisabled = (boolean)custSettingsFields.get(triggerFieldName);
            triggerEnabled = !(triggerDisabled || ASDAC_TriggerHandler.isBypassed(triggerHandlerName));
        }
        //Only if the trigger is enabled for this object then proceed
        if(triggerEnabled){
            try{
                //If the active function is set then it means that a trigger is currently running
                //therfore call the in progress entry of that trigger to provide any special handling
                //e.g recursion control
                if(activefunction!=null){
                    activefunction.inProgressEntry(inputParam);
                }
                //If no triggers are currently running then create a new instance of the appropriate
                //handler for that object
                else{
                    string typeName = triggerHandlerName;
                    Type t = Type.forName(typeName);
                    activefunction = (ASDAC_TriggerHandlerBase)t.newInstance();
                    activefunction.MainEntry(inputParam);
                }
            }
            catch(Exception ex){
               ASDAC_Logger.logException(ex);
            }
            finally {
              // ASDAC_Logger.writeLogsToDatabase()
            }
        }
    }
}