/**********************************************************************************
* @Component Type               : Apex Class
* @Component Name               : ASDAC_UpdateCasePayoutStatusBatchScheduler
* @description                  : Schedulable class to run ASDAC_UpdateCasePayoutStatusBatch at scheduled intervals
************************************************************************************/ 
public with sharing class ASDAC_ScheduleUpdateCasePayout implements Schedulable {
    
    /******************************************************************************************************
    * @description Schedulable method to execute the batch class at scheduled intervals.
    * @param sc - Schedulable context.
    ******************************************************************************************************/
    public void execute(SchedulableContext sc) {
        ASDAC_UpdateCasePayoutStatusBatch batchJob = new ASDAC_UpdateCasePayoutStatusBatch();
        Database.executeBatch(batchJob);
    }
}