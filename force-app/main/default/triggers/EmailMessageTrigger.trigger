/**********************************************************************************************
    @author        Sapient: Nitish Yadav
    @date          16 June 2022
    @description   EmailMessage Trigger
**********************************************************************************************/
trigger EmailMessageTrigger on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) { 
    ASDAC_TriggerFramworkService.triggerObj = ASDAC_GlobalConstants.OBJEMAILMESSAGE;
    new ASDAC_EmailMessageHandler().run();
}