/************************************************************************************
 * Class Name	: ASDAC_ChangeWorkQueueController
 * Developer	: Publicis Sapient
 * Created Date	: 08/05/2022
 * Purpose		: Update owner of case and insert justification public Case Comment
 * Reference	: ASDAC-1435
 * **********************************************************************************/
public with sharing class ASDAC_ChangeWorkQueueController {
	
	//Get the list of Queues
	//RETURN : List of ResponseWrapper wrapper
	@AuraEnabled(cacheable=true)
	public static ResponseWrapper getListOfQueues(){
		ResponseWrapper resWrap;
		List<String> excludedQueues = System.Label.ASDAC_ExcludedQueuesFromChangeWorkQueue.split(',');
        	String sobjectTypeName = System.Label.ASDAC_ChangeWorkQueueSobjectType;
		try {
			//Fetch list of Queues
			resWrap = new ResponseWrapper(true, '');
			resWrap.listOfQueues = [SELECT QueueId, Queue.Name FROM QueueSObject WHERE SobjectType =: sobjectTypeName and Queue.DeveloperName NOT IN :excludedQueues ORDER BY Queue.Name ASC ];
		} catch (Exception ex) {
			//Exception Logging in case of errors
			ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_ChangeWorkQueueController');
			ASDAC_Logger.writeLogsToDatabase();
			resWrap = new ResponseWrapper(false, ex.getMessage());
		}
		return resWrap;
	}

	//Update Case owner and insert Case comment for the transfer
	//RETURN : Boolean whether the process is successful or not
	@AuraEnabled
	public static ResponseWrapper updateCaseOwner(String caseId, String caseComment, String newOwnerId) {
        ResponseWrapper resWrap;
		try {
			//Fetch list of Queues
			List<Case> caseList = [SELECT Id, OwnerId, Comments FROM Case WHERE Id = :caseId WITH SECURITY_ENFORCED];
			if(caseList[0].ownerId == newOwnerId){
				return new ResponseWrapper(false, 'Selected owner is same as existing one.');
			}
            if(Case.SobjectType.getDescribe().isUpdateable()) {
				//Check if Case record is present and different owner is selected. Update Case record accordingly.
				if(!caseList.isEmpty()){
					caseList[0].Status = 'Available';
					caseList[0].ownerId = newOwnerId;
					caseList[0].Comments = String.isNotBlank(caseComment) ? caseComment : null;
				}
                //Check if Case comment is non blank and insert public case comment record
				Update caseList[0];
				resWrap = new ResponseWrapper(true, '');               
            }
            else {
				resWrap = new ResponseWrapper(false, String.format(Label.ASDAC_CreateRecordError, new List<Object>{'Case'}));
            }
		} catch(Exception ex){
			//Exception Logging in case of errors
			ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_ChangeWorkQueueController');
			ASDAC_Logger.writeLogsToDatabase();
			resWrap = new ResponseWrapper(false, Label.ASDAC_UpdateWorkQueueError);
		}
        return resWrap;
	}
	
	/**************************************************************************
	Purpose    : Wrapper Class to return data to LWC page.                                          
	Parameters : NA
	Returns    : NA                                               
	**************************************************************************/
	public class ResponseWrapper {
		@AuraEnabled public Boolean isSuccess;
		@AuraEnabled public String message;
		@AuraEnabled public List<QueueSObject> listOfQueues;
		public ResponseWrapper(Boolean isSuccess, String message) {
			this.isSuccess = isSuccess;
			this.message = message;
		}
	}
}