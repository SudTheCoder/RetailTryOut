/******************************************************************************
Name: ASDAC_CaseCommentHandler
===============================================================================
Req: 
ASDAC-19380 Prevent Deletion Of CaseComments
===============================================================================
Purpose:Handler class for CaseComment Trigger
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Sri Abhinaya    		27 March 2024    Initial Development
******************************************************************************/
public with sharing class ASDAC_CaseCommentHandler extends ASDAC_TriggerFramworkService{
    
    private Boolean contactCenterEnable = false;
    private List<CaseComment> lstOldCaseComment;
    private List<CaseComment> lstNewCaseComment;
    
    /**
    * @description constructor to assign trigger map 
    * @date 22-03-2024
    * @author Sri Abhinaya 
    **/
    public ASDAC_CaseCommentHandler() {
        this.lstOldCaseComment = (List<CaseComment>) Trigger.old;
        this.lstNewCaseComment = (List<CaseComment>) Trigger.new;
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
        this.execute('beforeDelete');		
    }
    
    /**
    * @description override method for before update
    * @date 18-04-2024
    * @author Sri Abhinaya
    **/
    public override void beforeUpdate() {
        this.execute('beforeUpdate');		
    }	
    
    /**
    * @description execute actual trigger context
    * @date 18-04-2024
    * @author Sri Abhinaya  
    **/
    private void execute(String type) {
		if(!this.contactCenterEnable) {
			return;
		}
		try {
			switch on type {
				when 'beforeUpdate' {
					restrictEditAccessForAgents(this.lstNewCaseComment);
				}
				when 'beforeDelete' {
					preventDeletion(this.lstOldCaseComment);
				}
				when else {
					//default CaseComment
					System.debug('no event initiated the trigger');
				}
			}
		} catch(Exception ex) {
			ASDAC_Logger.logException(ex);
			ASDAC_Logger.writeLogsToDatabase();
		}
	}
    
    /****************************************************************************
    @author        Sapient: Sri Abhinaya
    @date          22 March 2024
    @param         List<CaseComment> lstOldCaseComments
    @return        void
    @description   This method will prevent the Non Admin Contact Center Agents
                   from deleting the CaseComments.
    ****************************************************************************/
    private static void preventDeletion(List<CaseComment> lstOldCaseComments) {
        String currentUserProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        if(currentUserProfile != 'System Administrator') {
            for (CaseComment cc : lstOldCaseComments){
                // Throw an exception to prevent deletion
                cc.addError(System.Label.ASDAC_CaseCommentsDeletionErrorMessage);
            }
        }
   }
    
    /****************************************************************************
    @author        Sapient: Sri Abhinaya
    @date          18 April 2024
    @param         List<CaseComment> lstNewCaseComments
    @return        void
    @description   This method will prevent the Contact Center Agents
                       from editing the CaseComments.
    ****************************************************************************/
    private static void restrictEditAccessForAgents(List<CaseComment> lstNewCaseComments) {
        String currentUserProfile = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;

        if(currentUserProfile != 'System Administrator') {
        	for (CaseComment cc : lstNewCaseComments){
                	// Throw an exception to prevent deletion
                	cc.addError(System.Label.ASDAC_CaseCommentsRestrictEditAccessErrorMessage);
            }
        }
   }

}