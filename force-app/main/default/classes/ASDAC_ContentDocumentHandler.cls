/******************************************************************************
Name: ASDAC_ContentDocumentHandler
===============================================================================
Req: 
ASDAC-19020 Prevent Deletion Of ContentNote 
===============================================================================
Purpose:Handler class for Content Document Trigger
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Sri Abhinaya    		22 March 2024    Initial Development
******************************************************************************/
public with sharing class ASDAC_ContentDocumentHandler extends ASDAC_TriggerFramworkService{
    
    private Boolean contactCenterEnable = false;
    private List<ContentDocument> lstOldContentDocument;
    
    /**
    * @description constructor to assign trigger map 
    * @date 22-03-2024
    * @author Sri Abhinaya 
    **/
    public ASDAC_ContentDocumentHandler() {
        this.lstOldContentDocument = (List<ContentDocument>) Trigger.old;
        if (!ASDAC_ContactCentreSetting__c.getInstance().DisableContactCentre__c) {
			this.contactCenterEnable = true;
		}
    }
    
    /**
    * @description override method for before delete 
    * @date 22-03-2024
    * @author Sri Abhinaya
    **/
    public override void beforeDelete() {
        if(!this.contactCenterEnable) {
			return;
		}
        try {    
           preventDeletion(this.lstOldContentDocument);
        }catch(Exception ex) {
            ASDAC_Logger.logException(ex);
        }
    }
    
    /****************************************************************************
    @author        Sapient: Sri Abhinaya
    @date          22 March 2024
    @param         List<ContentDocument> lstOldContentDocuments
    @return        void
    @description   This method will prevent the Non Admin Contact Center Agents
                   from deleting the ContentNote records.
    ****************************************************************************/
    private static void preventDeletion(List<ContentDocument> lstOldContentDocuments) {
        String currentUserProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if(currentUserProfile != 'System Administrator') {
            for (ContentDocument cd : lstOldContentDocuments){
            	if(cd.FileType == 'SNOTE'){
                	// Throw an exception to prevent deletion
                	cd.addError(System.Label.ASDAC_NotesDeletionErrorMessage);
                }
            }
        }
    }

}