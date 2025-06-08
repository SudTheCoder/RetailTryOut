/*************************************************************************
Name: ASDAC_AssignToMeController
==========================================================================
Req: 
ASDAC-1696 Adding notes to a case not owned by the agent.
==========================================================================
Purpose: This Class will assign case to Agent When he clicks on 
		 "Assign To Me" button.     
==========================================================================
History                                                                                                                       
VERSION   AUTHOR                		DATE         	DETAIL
1.0       Shivakoti SaiAbhiteja    		17 June 2022    Initial Development
**************************************************************************/
public without sharing class ASDAC_AssignToMeController {
    
	/**************************************************************************
    Purpose    : This method will assign the case to the user who is clicking 
				 "Assign To Me" button.
    Parameters : Id recordId - Id of Case record
    Returns    : ResponseWrapper                                               
    **************************************************************************/
	@AuraEnabled  
  	public static ResponseWrapper assignToMe(Id recordId) {
        ResponseWrapper resWrap;
        try {
            Update new Case(Id = recordId, ownerId = UserInfo.getUserId(),comments= null);
			resWrap = new ResponseWrapper(true, ''); 
        }
      	catch(Exception ex) {
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_AssignToMeController');
            ASDAC_Logger.writeLogsToDatabase();
            resWrap = new ResponseWrapper(false, ex.getMessage()); 
		}
        return resWrap;
    }
    
    /**************************************************************************
    Purpose    : This method will assign the case to the user who is using Action Screen Flow.
    Parameters : List<List<Case>> Ids of Case record
    Returns    : void                                               
    **************************************************************************/
    @InvocableMethod
    public static void caseAssignToMe(List<List<Case>> lstRecordIds) {
        assignToMe(lstRecordIds[0][0].Id);
    }

	/**************************************************************************
    Purpose    : Wrapper Class to return data to LWC page.                                          
    Parameters : NA
    Returns    : NA                                               
    **************************************************************************/
    public class ResponseWrapper {
        @AuraEnabled public Boolean isSuccess{get; set;}
        @AuraEnabled public String message{get; set;}
        public ResponseWrapper(Boolean isSuccess, String message) {
			this.isSuccess = isSuccess;
            this.message = message;
        }
    }
}