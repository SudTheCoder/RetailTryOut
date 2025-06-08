/**********************************************************************************************
    @author        Sapient: Sri Abhinaya
    @date          08 April 2024
    @description   CaseComment Trigger
**********************************************************************************************/
trigger CaseCommentTrigger on CaseComment (before update, before delete) {
    ASDAC_TriggerFramworkService.triggerObj = ASDAC_GlobalConstants.OBJCASECOMMENT;
    new ASDAC_CaseCommentHandler().run();
}