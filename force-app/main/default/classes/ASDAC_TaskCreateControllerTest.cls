/******************************************************************************
Name: ASDAC_TaskCreateControllerTest
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
1.0       Rakesh Anapurapu    		23 Nov 2022     Initial Development
2.0       Disharee Ray              19 April 2023   ASDAC-9652 Fetch all the Tasks related to the order ID
******************************************************************************/
@isTest
public with sharing class ASDAC_TaskCreateControllerTest {
    
    @testsetup
    static void setup() {
      Account prsnAcc = ASDAC_TestDataUtility.createPersonAccount(false);
      prsnAcc.FirstName__pc = prsnAcc.FirstName;
      prsnAcc.LastName__pc = prsnAcc.LastName;
      insert prsnAcc;

      Log_Action__c logAction = new Log_Action__c();
      logAction.Subject__c = 'Order Check';
      logAction.Order_Number__c = 'Test123';
      logAction.Comments__c ='test comment';
      logAction.Related_To__c = prsnAcc.Id;
      logAction.Business_Area__c = 'George';
      insert logAction;

    }
    
    /**************************************************************************
	Purpose    : test method to test the task creation                                          
	Parameters : NA
	Returns    : NA                                        
	**************************************************************************/  
    @isTest
    public static void testCreateTask(){
        String description = 'Test description';
        String subject = 'Test subject';
        
        Test.startTest();
        ASDAC_TaskCreateController.responseWrapper resWrap = ASDAC_TaskCreateController.createTask(description, subject);
        System.assertEquals(true, resWrap.isSuccess);
        Test.stopTest();
    }
    
    /**************************************************************************
	Purpose    : test method to test the getTasks method                                          
	Parameters : NA
	Returns    : NA                                        
	**************************************************************************/  
    @isTest
    public static void getLogActions(){
        String orderid = 'Test123';
        Test.startTest();
        List<ASDAC_TaskCreateController.TaskWrapper> actionList= ASDAC_TaskCreateController.getLogActions(orderid);
        System.assertEquals(1, actionList.size(), 'Action list size matched!');
        System.assertEquals(orderid, actionList[0].orderNumber, 'Order Id matched!');
        Test.stopTest();
    }
    
}