/******************************************************************************
Name: ASDAC_RefundRequestController
===============================================================================
Req: 
ASDAC-3361 => Interface for Refunds - view order history and return actions
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                DATE         	DETAIL
1.0       Sanskriti Vijay       13-Oct-2022    Initial Development
2.0       Disharee Ray          28-March-2023  ASDAC-9872 modified escalatePartialRefund method.
******************************************************************************/

public with sharing class ASDAC_RefundRequestController {

    /**
	* ****************************************************************************************************
	* @param NA
	* @param NA
	* @description Order Items Wrapper class for UI
	* @return NA
	* ****************************************************************************************************
	*/
	public class OrderItemWrapper {
		@AuraEnabled public String lineId;
		@AuraEnabled public String productId;
		@AuraEnabled public String lineStatus;
		@AuraEnabled public String quantity;
		@AuraEnabled public String unitPrice;
		@AuraEnabled public String taxes;
		@AuraEnabled public String discount;
		@AuraEnabled public String lineTotal;
		@AuraEnabled public String percent;
		@AuraEnabled public Boolean isDisableCancel;
		@AuraEnabled public String orderId;
		@AuraEnabled public String refundReason ;
		@AuraEnabled public String refundAmount ;
		@AuraEnabled public String refundAmountSoFar;
		@AuraEnabled public String updatedLineAmount ;
		@AuraEnabled public String notes;
		@AuraEnabled public String refundType;
		@AuraEnabled public Boolean isDisableRefund;
		@AuraEnabled public Boolean isDisableExchange;
		@AuraEnabled public Boolean isDisableDiscount;
	}

	public class EscalateResponseWrapper{
		@AuraEnabled public Boolean escalate;
		@AuraEnabled public String approver;
	}
    
    /**
	* ****************************************************************************************************
	* @param : caseID, actionName- used to check the action name in the metadata and getting the respective case comments,
				totalRefund - total refund done as part of the OMS action.
	* @description : Creating records of CaseComment object related to the CaseId.
	* @return : Boolean check if records are created successfully
	* ****************************************************************************************************
	*/

	@AuraEnabled
	public static Boolean createCaseComment(String caseID, String actionName, String totalRefund){
		String caseCommentStr;
        List<ASDAC_OMSActionsCaseComment__mdt> mdtRecordList = new List<ASDAC_OMSActionsCaseComment__mdt>();
		try{
			mdtRecordList = [Select Id, ActionName__c,CaseComment__c
							From ASDAC_OMSActionsCaseComment__mdt where ActionName__c =: actionName];
	
			caseCommentStr = String.format(mdtRecordList[0].CaseComment__c, new List<String>{ totalRefund, UserInfo.getName() });
			if(('Exchange').equalsIgnoreCase(actionName)){
				caseCommentStr = String.format(mdtRecordList[0].CaseComment__c, new List<String>{UserInfo.getName() });	
			}
			
			List<CaseComment> commentList = new List<CaseComment>();
			CaseComment commentRecord = new CaseComment();
			commentRecord.ParentId = caseID;
			commentRecord.CommentBody = caseCommentStr;
			commentList.add(commentRecord);
			if(!commentList.isEmpty()){
				Database.insert(commentList);
			}
			return true;
		}
		catch (Exception e) {
			ASDAC_Logger.logException(e, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_RefundRequestController');
            ASDAC_Logger.writeLogsToDatabase();
            return false;
        }
    }
    /**
    * ****************************************************************************************************
    * @param : 
    * @description : Return the contact name associated with a particualr order
    * @return : Contact name String
    * ****************************************************************************************************
    */
    @AuraEnabled
    public static String getPersonContactId(String customerId){
        List<Account> accList = [Select id, PersonContactId, PersonContact.Name from Account where PersonContactId =: customerId Limit 1];
        if(!accList.IsEmpty()){
            return accList[0].PersonContact.Name;
        }
        return null;
    }

	/**
	* ****************************************************************************************************
	* @param : userRole, refundPercent
	* @description : checks in the metadata for the role limits given  to the user role, if the refund percentage selected by them should be escalated or not
	* @return : Returns a wrapper object with one boolean flag for escalation and a string which contains the team name to which the escalation will be done.
	* ****************************************************************************************************
	*/
	@AuraEnabled
	public static EscalateResponseWrapper escalatePartialRefund(String userRole, String refundPercent){
		Boolean escalate = false;
		Decimal percentage = Decimal.valueOf(refundPercent).setScale(2);
		String approver;
		EscalateResponseWrapper resWrap = new EscalateResponseWrapper();
		try{
            for(ASDAC_PartialRefundApprovalsMapping__mdt prm:ASDAC_PartialRefundApprovalsMapping__mdt.getAll().values()){
                if((prm.MasterLabel==userRole) && (percentage < prm.LowerLimit__c || percentage > prm.UpperLimit__c)){
			        escalate = true; 
                }
            }
			resWrap.escalate = escalate;
			resWrap.approver = approver;       
		}
		catch (Exception e) {
			ASDAC_Logger.logException(e, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, '', 'ASDAC_RefundRequestController');
            ASDAC_Logger.writeLogsToDatabase();
		}		
		return resWrap;
	}
}