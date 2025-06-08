/**
* @author -         Disharee Ray- Publicis Sapient
* @date -           18 March 2024
* @description -    APEX JOB TO update Order fulfilled date on case record
* Modified by     Version     Change Date
**/

/*
 *********************EXAMPLE TO USE IT **********************************
  batch job that updates case order fulfilled date field with the order being linked to the Case & Contact reason level 2 equals VAT receipt (grocery business area).

  Database.executeBatch(new ASDAC_UpdateCaseOrderFulfilledDateBatch(),100);

  Here is an example of a schedule job, which updates the Order fulfilled date on Case if the linked order is already fulfilled.
  System.schedule('Update Case Order fulfilled date batch job', '0 01 00 * * ? *', new ASDAC_UpdateCaseOrderFulfilledDateBatch());
*/

/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer             Date            Description
*---------------------------------------------------------------------------------------------------
* DISHAREE RAY          18.2.2024       Created Apex                                                
***************************************************************************************************/
public with sharing class ASDAC_UpdateCaseOrderFulfilledDateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful,Schedulable{
    private final static String ORDER_DETAILS_GHS_ENDPOINT_MDT = ASDAC_OMSConstants.STRING_ORDERDETAILGHS;
    private final static String CLASS_NAME = 'ASDAC_UpdateCaseOrderFulfilledDateBatch';
    private Integer retryCount;
    String exceptionMessage = '';
    List<Case> caseListTobeUpdated = new List<Case>();
    String query = 'SELECT Id, ContactReasonLevel2__c, Status, DaysSinceFulfill__c, OrderFulfilledDate__c,OrderId__c,BusinessArea__c  ' +
        'FROM Case ' +
        'WHERE ContactReasonLevel2__c =\'' +ASDAC_GlobalConstants.STRING_VAT_RECEIPT + '\' ' +
        'AND Status != \'' +ASDAC_GlobalConstants.STRING_STATUS_CLOSED + '\' ' +
        'AND DaysSinceFulfill__c = null '+
        'AND BusinessArea__c =\''+ASDAC_GlobalConstants.STRING_GROCERY_CASE_BUSINESSAREA +'\' ' +
        'AND OrderId__c!=null';   
    
    public ASDAC_UpdateCaseOrderFulfilledDateBatch() {
        this.retryCount = 0;
    }
    
    public ASDAC_UpdateCaseOrderFulfilledDateBatch(Integer retries) {
        this.retryCount = retries;
    }    
    public Database.querylocator start(Database.BatchableContext batchContext){
        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext batchContext, List<Case> caseList){
        String integrationMetadata =ORDER_DETAILS_GHS_ENDPOINT_MDT;
        for(Case cs : caseList){
            if(String.isNotBlank(cs.OrderId__c)){ 
                try{
                    ASDAC_OrderResponse orderResponse = ASDAC_OrderService.getOrder(ASDAC_OMSConstants.ASDA_GROCERIES_STRING,cs.OrderId__c,new List<String>(),integrationMetadata);
                    if(orderResponse!=null && orderResponse.orderFulfilledDate!=null){
                        caseListTobeUpdated.add(new Case(Id=cs.Id,OrderFulfilledDate__c=orderResponse.orderFulfilledDate));
                    }
                }  
                catch(Exception exp) {
                    exceptionMessage+= exp.getMessage() + '\n';
                }     
            } 
        }
        if(exceptionMessage!=''){
            Log__c log = new Log__c( 
                LogType__c = ASDAC_GlobalConstants.STRING_EXCEPTION_LOGTYPE,
                User__c = UserInfo.getUserId(),
                ApexClass__c=CLASS_NAME,
                Message__c=exceptionMessage
            );
            if(Log__c.SobjectType.getDescribe().isCreateable()) {
                insert log;      
            }          
        }
    }
    public void finish(Database.BatchableContext batchContext){
        Database.SaveResult[] srList = Database.update(caseListTobeUpdated, false);
        Boolean isRetryEnabled=false;
        // Iterate through each returned result
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                isRetryEnabled=true;
                break;             
            }
        }
        if (retryCount < 3 && isRetryEnabled) {
            Database.executeBatch(new ASDAC_UpdateCaseOrderFulfilledDateBatch(retryCount++),100);
        }
    }
    
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new ASDAC_UpdateCaseOrderFulfilledDateBatch(),100);  
    }
}