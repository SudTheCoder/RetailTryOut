/***************************************************************************************************************
* @author                      : Kishor Chand
* @date                        : 2023-Feb-15
* @description   : ASDAC_DeleteRecordsBatchable_Test class to test ASDAC_DeleteRecordsBatchable class.
***************************************************************************************************************/
@isTest
private with sharing class ASDAC_DeleteRecordsBatchable_Test {
  private static final String JOBID_ERROR = 'Job Id should not be null';
  private static final String ASYNC_JOB_ERROR = 'Not expecting any asyncjobs';
  private static final String SCHEDULED_JOB_ERROR = 'Expecting one scheduled job';
  private static final String SCHEDULED_APEX_CLASSNAME_ERROR = 'Expecting scheduled apex class name to be ASDAC_DeleteRecordsBatchable';
  private static final String BATCH_JOB_ERROR = 'Expecting one apex batch job';
  private static final String BATCH_APEX_CLASSNAME_ERROR = 'Expecting scheduled batch apex class name to be ASDAC_DeleteRecordsBatchable';
  private static final string ACCOUNT_HANDLER = 'ASDAC_AccountHandler';

/**************************************************************************************************************
* @author       : Kishor Chand
* @date         : 2023-Feb-15
* @description  : tests did the required Apex Batch and Scheduler get posted to the queue and Accounts got successfully deleted
* @param        : none
* @return       : void
***************************************************************************************************************/    
   @isTest static void testScheduler() {
       //create Account records
       List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(200, false);
       ASDAC_TriggerHandler.bypass(ACCOUNT_HANDLER);
       Insert lstAccount;
       ASDAC_TriggerHandler.clearBypass(ACCOUNT_HANDLER);
       //setup the scheduler
       String cronExp = '0 0 0 ? * SAT *';
       String query = 'SELECT ID FROM Account';
       //testing that no scheduled jobs or batch jobs are queued
       List<AsyncApexJob> jobsBefore = [SELECT Id, ApexClassID, ApexClass.Name, Status, JobType
                                        FROM AsyncApexJob];
       System.assertEquals(0, jobsBefore.size(), ASYNC_JOB_ERROR);
       
       Test.startTest();
       String jobId = System.schedule('ASDAC_DeleteRecordsBatchableTest', cronExp, new ASDAC_DeleteRecordsBatchable(query));
       System.assertNotEquals(null, jobId, JOBID_ERROR);
       Test.stopTest();
       //testing that only one scheduled job is available with the intended class name
       List<AsyncApexJob> jobsScheduled = [SELECT ApexClass.Name, JobType 
                                           FROM AsyncApexJob 
                                           WHERE JobType = 'ScheduledApex'];
       System.assertEquals(1, jobsScheduled.size(), SCHEDULED_JOB_ERROR);
       System.assertEquals('ASDAC_DeleteRecordsBatchable', jobsScheduled[0].ApexClass.Name, SCHEDULED_APEX_CLASSNAME_ERROR);
       
       //testing that only one batch job is available with the intended class name
       List<AsyncApexJob> jobsApexBatch = [SELECT ApexClass.Name, JobType 
                                           FROM AsyncApexJob 
                                           WHERE JobType = 'BatchApex'];
       System.assertEquals(1, jobsApexBatch.size(),BATCH_JOB_ERROR);
       System.assertEquals('ASDAC_DeleteRecordsBatchable', jobsApexBatch[0].ApexClass.Name, BATCH_APEX_CLASSNAME_ERROR);
    } 
}