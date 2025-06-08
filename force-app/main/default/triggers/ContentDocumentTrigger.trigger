/**********************************************************************************************
    @author        Sapient: Sri Abhinaya
    @date          22 March 2024
    @description   ContentDocument Trigger
**********************************************************************************************/
trigger ContentDocumentTrigger on ContentDocument (before delete) {
    ASDAC_TriggerFramworkService.triggerObj = ASDAC_GlobalConstants.OBJCONTENTDOCUMENT;
    new ASDAC_ContentDocumentHandler().run();
}