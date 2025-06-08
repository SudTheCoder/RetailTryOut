/******************************************************************************
Name: ASDAC_ContentDocumentLinkHandler
===============================================================================
Req: 
ASDAC-20159 Prevent Deletion Of ContentDocumentLink 
===============================================================================
Purpose:Handler class for Content Document Link Trigger
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Sri Abhinaya    		09 May 2024    Initial Development
******************************************************************************/
public with sharing class ASDAC_ContentDocumentLinkHandler extends ASDAC_TriggerFramworkService{
    private Boolean contactCenterEnable = false;
    private List<ContentDocumentLink> lstOldContentDocumentLink;
    
    /**
	* @description constructor to assign trigger map 
	* @date 22-03-2024
	* @author Sri Abhinaya 
	**/
    public ASDAC_ContentDocumentLinkHandler() {
        this.lstOldContentDocumentLink = (List<ContentDocumentLink>) Trigger.old;
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
           preventDeletion(this.lstOldContentDocumentLink);
        }catch(Exception ex) {
            ASDAC_Logger.logException(ex);
        }
    }
    
    /****************************************************************************
	@author        Sapient: Sri Abhinaya
	@date          22 March 2024
	@param         List<ContentDocumentLink> lstOldContentDocumentLinks
	@return        void
	@description   This method will prevent the Non Admin Contact Center Agents
    from deleting the ContentDocumentLink records.
	****************************************************************************/
    private static void preventDeletion(List<ContentDocumentLink> lstOldContentDocumentLinks) {
        String currentUserProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
        if(currentUserProfile != 'System Administrator') {
        	for (ContentDocumentLink cdl : lstOldContentDocumentLinks){
            	if(String.valueOf(cdl.LinkedEntityId).startsWith('001') == true){
                	// Throw an exception to prevent deletion
                	cdl.addError(System.Label.ASDAC_ContentDocumentLinkDeletionErrorMessage);
                }
            }
        }
    }
}