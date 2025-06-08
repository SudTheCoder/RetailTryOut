/******************************************************************************
Name: ASDAC_TaskCreateController
===============================================================================
Req: 
ASDAC-3538 Create task record
ASDAC-9652 => Log action | George | RFI / Chargeback
===============================================================================
Create task based on user's feedback 
Log action | George | RFI / Chargeback
===============================================================================
History                                                                                                                       
VERSION   AUTHOR                	DATE         	DETAIL
1.0       Rakesh Anapurapu    		19 Nov 2022     Initial Development
2.0       Disharee Ray              18 April 2023   ASDAC-9652 Fetch all the Tasks related to the order ID
3.0       Disharee Ray              30 June 2023    ASDAC-12817 Refactored getLogActions method
******************************************************************************/
public with sharing class ASDAC_TaskCreateController {
  /**************************************************************************
    Purpose    : To create a task record
    Parameters : String task Description, String task subject
    Returns    : ResponseWrapper                                               
    **************************************************************************/

  @AuraEnabled
  public static ResponseWrapper createTask(String description, String subject) {
    ResponseWrapper resWrap;
    Task tsk = new Task();
    try {
      Group grp = [
        SELECT Id, Name, Type
        FROM Group
        WHERE Type = 'Queue' AND Name = 'Content Feedback'
        LIMIT 1
      ];
      if (description != null && subject != null) {
        tsk.Subject = subject;
        tsk.Description = description;
        tsk.Priority = ASDAC_GlobalConstants.TASK_PRIORITY;
        tsk.Status = ASDAC_GlobalConstants.TASK_STATUS;
        tsk.OwnerId = grp.Id;
        insert tsk;
        resWrap = new ResponseWrapper(
          true,
          ASDAC_GlobalConstants.SUCCESSAPINAME
        );
      }
    } catch (Exception ex) {
      resWrap = new ResponseWrapper(false, ex.getMessage());
    }
    return resWrap;
  }

    
    /**
	* ****************************************************************************************************
	* @param : 
	* @description fetch all Log_Action__c records related to order ID.
	* @return list of Log_Action__c records
	* ****************************************************************************************************
	*/
    @AuraEnabled(cacheable=true)
    public static List<TaskWrapper> getLogActions(String orderid){
      List<Log_Action__c> logActionsList;
      List<TaskWrapper> taskWrapperList = new List<TaskWrapper>();
      try{
        String query = 'SELECT Id,Name,ActionTaken__c,Subject__c,DisputeValue__c,CreatedDate,Charge_amount__c,'+
                        'Order_Number__c,Reason__c,RefundValue__c FROM Log_Action__c WHERE Order_Number__c=:orderid WITH SECURITY_ENFORCED ';
        logActionsList = Database.query(query);
        
        for(Log_Action__c logActionsRecord: logActionsList){
          TaskWrapper taskWrap = new TaskWrapper();
          taskWrap.id = logActionsRecord.Id;
          taskWrap.name = logActionsRecord.Name;
          taskWrap.actionTaken = logActionsRecord.ActionTaken__c;
          taskWrap.subject = logActionsRecord.Subject__c;
          taskWrap.disputeValue = logActionsRecord.DisputeValue__c;
          taskWrap.chargeAmount = logActionsRecord.Charge_amount__c;
          taskWrap.orderNumber = logActionsRecord.Order_Number__c;
          taskWrap.reason = logActionsRecord.Reason__c;
          taskWrap.refundValue = logActionsRecord.RefundValue__c;
          taskWrap.CreatedDate = logActionsRecord.CreatedDate;
          taskWrapperList.add(taskWrap);
        }
      }catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
      }
      return taskWrapperList; 
    }

    public class TaskWrapper {
      @AuraEnabled public String id;
      @AuraEnabled public String name;
      @AuraEnabled public String actionTaken;
      @AuraEnabled public String subject;
      @AuraEnabled public Decimal disputeValue;
      @AuraEnabled public DateTime CreatedDate;
      @AuraEnabled public Decimal chargeAmount;
      @AuraEnabled public String orderNumber;
      @AuraEnabled public String reason;
      @AuraEnabled public Decimal refundValue;

      @AuraEnabled public String formattedCreatedDate {
          get {
              return ASDAC_OrderUtility.convertDateTimeString(CreatedDate);
          }
      }
  }
    
  /**************************************************************************
    Purpose    : Wrapper Class to return data to LWC page.                                          
    Parameters : NA
    Returns    : NA                                               
    **************************************************************************/
  public class ResponseWrapper {
    @AuraEnabled
    public Boolean isSuccess;
    @AuraEnabled
    public String message;
    public ResponseWrapper(Boolean isSuccess, String message) {
      this.isSuccess = isSuccess;
      this.message = message;
    }
  }
}