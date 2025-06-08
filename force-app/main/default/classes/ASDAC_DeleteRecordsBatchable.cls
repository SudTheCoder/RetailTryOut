/**
* @author -         Dependra Singh- Publicis Sapient
* @date -           23 May 2022
* @description -    APEX JOB TO DELETE RECORDS
* Modified by     Version     Change Date
**/

/*
 *********************EXAMPLE TO USE IT **********************************
//batch job that deletes accounts that does not have any activities for the last one years.

DeleteRecordsJob j = new DeleteRecordsJob('SELECT ID FROM Account WHERE LastActivityDate < LAST_N_YEARS:1');
Database.executeBatch(j);

//Here is an example of a schedule job, which deletes all the converted leads every Saturday.
DeleteRecordsJob j = new DeleteRecordsJob('SELECT ID FROM Lead WHERE IsConverted = TRUE');
System.schedule('Delete Converted Leads', '0 0 0 ? * SAT *', j);
*/

/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Kishor Chand                  15-Feb-2023     Added Schedulable interface                                                
***************************************************************************************************/

public with sharing class ASDAC_DeleteRecordsBatchable implements Schedulable,Database.Batchable<sObject> {
  private final String query;
  
  public ASDAC_DeleteRecordsBatchable(String query) {
    this.query = query;
  }

  // Database.Batchable methods
  public Database.QueryLocator start(Database.BatchableContext bc) {
    return Database.getQueryLocator(query);
  }
  
  public void execute(Database.BatchableContext bc, List<sObject> scope) {
    delete scope;
  }
  
  public void finish(Database.BatchableContext bc) {
  }
  public void execute(SchedulableContext ctx) {
    Database.executeBatch(new ASDAC_DeleteRecordsBatchable(query));  
  }
}