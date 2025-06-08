/**********************************************************************************************
@author    		Sapient : Ramdev Chahar
@date      		5 August 2022
@description: 	Test Class for ASDAC_TriggerHandler 
**********************************************************************************************/
@IsTest
public class ASDAC_TriggerHandler_Test {
    public static final String HANDLERNAME = 'ASDAC_ContactPointAddressHandler';
    public static final String VALUE_SHOULD_NOT_BE_FALSE_MSG = 'Value should not be false';
    public static final String VALUE_SHOULD_BE_FALSE_MSG = 'Value should be false';
    public static final String ALL_TRIGGER_SHOULD_BE_BYPASSED_MSG = 'All trigger should be bypassed';
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		5 August 2022
	@description	This method for bypass trigger ASDAC_TriggerHandler.bypass
	**********************************************************************************************/
    @isTest
    static void testByPass() {
        test.startTest();
            ASDAC_TriggerHandler.bypass(HANDLERNAME);
        test.stopTest();
        System.assertEquals(true, ASDAC_TriggerHandler.isBypassed(HANDLERNAME), VALUE_SHOULD_NOT_BE_FALSE_MSG);
    }
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		5 August 2022
	@description	This method for ASDAC_TriggerHandler.clearBypass
	**********************************************************************************************/
    @isTest
    static void testClearByPass() {
        ASDAC_TriggerHandler.bypass(HANDLERNAME);
        test.startTest();
            ASDAC_TriggerHandler.clearBypass(HANDLERNAME);
        test.stopTest();
        System.assertEquals(false, ASDAC_TriggerHandler.isBypassed(HANDLERNAME),VALUE_SHOULD_BE_FALSE_MSG);
    }
    /**********************************************************************************************
	@author      	Sapient : Ramdev Chahar
	@date      		5 August 2022
	@description	This method for ASDAC_TriggerHandler.clearAllBypasses
	**********************************************************************************************/
    @isTest
    static void testClearAllByPasses() {
        ASDAC_TriggerHandler.bypass(HANDLERNAME);
        test.startTest();
            ASDAC_TriggerHandler.clearAllBypasses();
        test.stopTest();
        System.assertEquals(0, ASDAC_TriggerHandler.bypassedHandlers.size(),ALL_TRIGGER_SHOULD_BE_BYPASSED_MSG);
    }
}