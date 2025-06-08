/**********************************************************************************************
    @author        Sapient: Sri Abhinaya
    @date          09 May 2024
    @description   ContentDocumentLink Trigger
**********************************************************************************************/
trigger ContentDocumentLinkTrigger on ContentDocumentLink (before delete) {
	ASDAC_TriggerFramworkService.triggerObj = ASDAC_GlobalConstants.OBJCONTENTDOCUMENTLINK;
    new ASDAC_ContentDocumentLinkHandler().run();
}