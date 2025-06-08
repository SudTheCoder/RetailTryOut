/**********************************************************************************************
    @author        Sapient: Ramdev Chahar
    @date          22 August 2022
    @description   Contact Point Consent Trigger
**********************************************************************************************/
trigger ContactPointConsentTrigger on ContactPointConsent (before insert, before update) {

  if((ASDAC_TriggerSetting__mdt.getInstance('Enable_New_Trigger_Framework').IsActive__c == true && !ASDAC_TriggerHandlerObj.enableOldTriggerFramework)
        ||(ASDAC_TriggerSetting__mdt.getInstance('Enable_New_Trigger_Framework').IsActive__c == false && Test.isRunningTest() && !ASDAC_TriggerHandlerObj.enableOldTriggerFramework)){
    ASDAC_TriggerFramworkService.triggerObj = ASDAC_GlobalConstants.OBJCONTACTPOINTCONSENT;
    new ASDAC_ContactPointConsentTriggerHandler().run();
}else{
    //Create a new parameters object for the trigger handler
    ASDAC_TriggerHandlerObj trigObj = new ASDAC_TriggerHandlerObj();
    //Update the object with trigger properties
    trigObj.triggerObject = ASDAC_GlobalConstants.OBJCONTACTPOINTCONSENT;
    trigObj.isBefore = trigger.isBefore;
    trigObj.isDelete = trigger.isDelete;
    trigObj.isAfter =  trigger.isAfter;
    trigObj.isInsert = trigger.isInsert;
    trigObj.isUpdate = trigger.isUpdate;
    trigObj.isExecuting = trigger.isExecuting;
    trigObj.newlist = trigger.new;
    trigObj.newmap =  trigger.newmap;
    trigObj.oldlist = trigger.old;
    trigObj.oldmap = trigger.oldmap;

    //Invoke the central dispatcher with the parameter object
    ASDAC_TriggerCentralDispatcher.mainEntry(trigObj);
}
   
}