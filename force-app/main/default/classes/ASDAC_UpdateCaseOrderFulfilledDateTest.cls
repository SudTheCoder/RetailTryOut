/***************************************************************************************************************
* @author        : Disharee Ray
* @date          : 2024-March-118
* @description   : ASDAC_UpdateCaseOrderFulfilledDateTest class to test ASDAC_UpdateCaseOrderFulfilledDateBatch class.
***************************************************************************************************************/
@isTest
public with sharing class ASDAC_UpdateCaseOrderFulfilledDateTest {
private final static String ORDER_MOCK_RESOURCE_NAME = 'SampleGetOrderMock';
private final static String TECHNICAL_EXCEPTION_MESSAGE = 'Internal Server Error';
public static final String ORDER_ID = 'AP-202205160031';
public static final String JOBID_ERROR = 'Job Id should not be null';
public static final String ASYNC_JOB_ERROR = 'Not expecting any asyncjobs';
public static final String SCHEDULED_JOB_ERROR = 'Expecting one scheduled job';
public static final String SCHEDULED_APEX_CLASSNAME_ERROR = 'Expecting scheduled apex class name to be ASDAC_UpdateCaseOrderFulfilledDateBatch';
public static final String BATCH_JOB_ERROR = 'Expecting one apex batch job';
public static final String BATCH_APEX_CLASSNAME_ERROR = 'Expecting scheduled batch apex class name to be ASDAC_UpdateCaseOrderFulfilledDateBatch';
public static final String BATCH_JOB_COMPLETION_ERROR = 'Expecting one apex batch job to be completed';
public static final String BATCH_JOB_EXTENDED_STATUS_ERROR = 'Batch job extended status should be null on succesful completion';
public static final String BATCH_JOB_LOG_GENERATED_ERROR = 'Some error occurred on executing the Batch job';
    
@testSetup
    public static void createData() {
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, ASDAC_GlobalConstants.STRING_ASDA_BASE_PROFILE)[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + ASDAC_GlobalConstants.STRING_ASDABASE_SUFFIX;
        insert ocsASDABaseUser;
        ASDAC_TestDataUtility.assignPermissionSetGroup(new List<User>{ocsASDABaseUser},ASDAC_GlobalConstants.STRING_TEAMLEAD_UK_PSG_NAME);
        Group vatRequestQueue = getVATQueueRecord();
        system.runAs(ocsASDABaseUser) {
           Account personAccount = ASDAC_TestDataUtility.createPersonAccount(true);
            Id recTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            Case newcaseObj = new Case(Origin = 'Email',
                                    RecordTypeId = recTypeId,
                                    AccountId = personAccount.Id,
                                    Subject = 'Test Case 1' ,
                                    Status = Label.ASDAC_DefaultCaseStatus,
                                    WorkQueue__c ='Grocery - VAT Requests',
                                    OwnerId = vatRequestQueue.Id,
                                    OrderId__c=ORDER_ID,
                                    ContactReasonLevel1__c = 'Payment & Refunds',
                                    ContactReasonLevel2__c = 'VAT Receipt',
                                    BusinessArea__c='Grocery'
                                    );
            insert newcaseObj;
        }
    }
    
     /**************************************************************************
     Purpose    : method to get VAT Requests Queue                                   
     Parameters : NA
     Returns    : NA                                        
    **************************************************************************/ 
    private static Group getVATQueueRecord() {
        return [SELECT Id, Name, DeveloperName FROM Group WHERE Type = 'Queue' AND DeveloperName = 'VATRequests' LIMIT 1];
    }
    
    
     @isTest
    static void updateCaseOrderFulfilledDateSuccessTest() {
        Case cs = [Select id,Subject from Case where Subject = 'Test Case 1' limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(ORDER_MOCK_RESOURCE_NAME));
        ASDAC_UpdateCaseOrderFulfilledDateBatch batch = new ASDAC_UpdateCaseOrderFulfilledDateBatch();  
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
        System.assertEquals('Completed', job.Status,BATCH_JOB_COMPLETION_ERROR);
        System.assertEquals(null, job.ExtendedStatus,BATCH_JOB_EXTENDED_STATUS_ERROR);
        
    }
    
    @isTest
    static void updateCaseOrderFulfilledDateFailTest() {
        Case cs = [Select id,Subject from Case where Subject = 'Test Case 1' limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));
        ASDAC_UpdateCaseOrderFulfilledDateBatch batch = new ASDAC_UpdateCaseOrderFulfilledDateBatch();  
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
        System.assertEquals('Completed', job.Status,BATCH_JOB_COMPLETION_ERROR);
        System.assertEquals(null, job.ExtendedStatus,BATCH_JOB_EXTENDED_STATUS_ERROR);
        List<Log__c> loglist=[SELECT Id, ApexClass__c,Message__c FROM Log__c];
        System.assertEquals(1, loglist.size(),BATCH_JOB_LOG_GENERATED_ERROR);
        System.assertEquals(TECHNICAL_EXCEPTION_MESSAGE, loglist[0].Message__c,BATCH_JOB_LOG_GENERATED_ERROR);
    }
    
    @isTest
    static void updateCaseOrderFulfilledDateRetryTest() {
        Case cs = [Select id,Subject from Case where Subject = 'Test Case 1' limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ASDAC_OrderIntegrationServiceMock_Test(500, TECHNICAL_EXCEPTION_MESSAGE));
        ASDAC_UpdateCaseOrderFulfilledDateBatch batch = new ASDAC_UpdateCaseOrderFulfilledDateBatch(1);  
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        AsyncApexJob job = [SELECT Id, Status, ExtendedStatus FROM AsyncApexJob WHERE Id = :batchId LIMIT 1];
        System.assertEquals('Completed', job.Status,BATCH_JOB_COMPLETION_ERROR);
        System.assertEquals(null, job.ExtendedStatus,BATCH_JOB_EXTENDED_STATUS_ERROR);
        List<Log__c> loglist=[SELECT Id, ApexClass__c,Message__c FROM Log__c];
        System.assertEquals(1, loglist.size(),BATCH_JOB_LOG_GENERATED_ERROR);
        System.assertEquals(TECHNICAL_EXCEPTION_MESSAGE, loglist[0].Message__c,BATCH_JOB_LOG_GENERATED_ERROR);
    }
    
    @isTest
    static void batchSchedulerTest() {
      String cronExp = '0 01 00 * * ? *';
       //testing that no scheduled jobs or batch jobs are queued
       List<AsyncApexJob> jobsBefore = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
                                        FROM AsyncApexJob];
       System.assertEquals(0, jobsBefore.size(), ASYNC_JOB_ERROR);
       Test.startTest();
       String jobId = System.schedule('ASDAC_UpdateCaseOrderFulfilledDateTest', cronExp, new ASDAC_UpdateCaseOrderFulfilledDateBatch());
       System.assertNotEquals(null, jobId,JOBID_ERROR);
       Test.stopTest();
       //testing that only one scheduled job is available with the intended class name
       List<AsyncApexJob> jobsScheduled = [SELECT ApexClass.Name, JobType 
                                           FROM AsyncApexJob 
                                           WHERE JobType = 'ScheduledApex'];
       System.assertEquals(1, jobsScheduled.size(), SCHEDULED_JOB_ERROR);
       System.assertEquals('ASDAC_UpdateCaseOrderFulfilledDateBatch', jobsScheduled[0].ApexClass.Name, SCHEDULED_APEX_CLASSNAME_ERROR);
       
       //testing that only one batch job is available with the intended class name
       List<AsyncApexJob> jobsApexBatch = [SELECT ApexClass.Name, JobType 
                                           FROM AsyncApexJob 
                                           WHERE JobType = 'BatchApex'];
       System.assertEquals(1, jobsApexBatch.size(),BATCH_JOB_ERROR);
       System.assertEquals('ASDAC_UpdateCaseOrderFulfilledDateBatch', jobsApexBatch[0].ApexClass.Name, BATCH_APEX_CLASSNAME_ERROR);  
    }
}