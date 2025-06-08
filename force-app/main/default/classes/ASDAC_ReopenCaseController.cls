/*************************************************************************
Name: ASDAC_ReopenCaseController
==========================================================================
Req: 
ASDAC-1696 Adding notes to a case not owned by the agent.
==========================================================================
Purpose: This Class will Reopen case to Agent When he clicks on 
		 "Re Open Case" button.     
==========================================================================
History                                                                                                                       
VERSION   AUTHOR                		DATE         	DETAIL
1.0       Shivakoti SaiAbhiteja    		     Initial Development
**************************************************************************/
public with sharing class ASDAC_ReopenCaseController {
  /**************************************************************************
    Purpose    : This method will assign the case to the user who is clicking 
				 "Reopen Case" button.
    Parameters : Id recordId - Id of Case record
    Returns    : ResponseWrapper                                               
    **************************************************************************/
  @AuraEnabled
  public static ResponseWrapper reOpenToMe(Id recordId) {
    ResponseWrapper resWrap;
    try {
      ASDAC_WithoutSharingUtility.reOpenCase(recordId);
      resWrap = new ResponseWrapper(true, '');
    } catch (Exception ex) {
      ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '','ASDAC_ReOpenToMeController');
      ASDAC_Logger.writeLogsToDatabase();
      resWrap = new ResponseWrapper(false, ex.getMessage());
	  system.debug ('resWrapUpdated'+resWrap);
    }
    return resWrap;
  }

  /**************************************************************************
    Purpose    : Wrapper Class to return data to LWC page.                                          
    Parameters : NA
    Returns    : NA                                               
    **************************************************************************/
  public class ResponseWrapper {
    @AuraEnabled
    public Boolean isSuccess { get; set; }
    @AuraEnabled
    public String message { get; set; }
    public ResponseWrapper(Boolean isSuccess, String message) {
      this.isSuccess = isSuccess;
      this.message = message;
    }
  }
}