/**********************************************************************************************
    @author        Sapient: Nitish Yadav
    @date          25 July 2022
    @description   Case Trigger
**********************************************************************************************/
trigger CaseTrigger on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    ASDAC_TriggerFramworkService.triggerObj = ASDAC_GlobalConstants.OBJCASE;
    new ASDAC_CaseHandler().run();
}