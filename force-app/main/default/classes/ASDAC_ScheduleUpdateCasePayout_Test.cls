@isTest
public with sharing class ASDAC_ScheduleUpdateCasePayout_Test {
    @isTest
    static void execute_verifyJobSchedule_scheduleJobToFuture() {
        // Create an instance of the schedulable class
        ASDAC_ScheduleUpdateCasePayout schedulableInstance = new ASDAC_ScheduleUpdateCasePayout();
        String cronExpression = '0 0 0 1 1 ? 2125';
        Test.startTest();
        // Schedule the job
        String jobId = System.schedule('Test Job ASDAC_ScheduleUpdateCasePayout', cronExpression, schedulableInstance);

        // Get the information from the CronTrigger API object
        CronTrigger ct = [
                        SELECT Id, CronExpression, TimesTriggered, NextFireTime
                        FROM CronTrigger 
                        WHERE id = :jobId
        ];
        
        Test.stopTest();

        // Verify the expressions are the same
        Assert.areEqual(cronExpression, ct.CronExpression, 'The cron expressions are not the same');

        // Verify the job has not run
        Assert.areEqual(0, ct.TimesTriggered, 'The job has been executed');

        // Verify the next time the job will run
        Assert.areEqual('2125-01-01 00:00:00', String.valueOf(ct.NextFireTime), 'The next scheduled execution time for the job is incorrect');        
    }
}