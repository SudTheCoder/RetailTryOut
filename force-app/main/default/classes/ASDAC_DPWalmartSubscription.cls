/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2024-08-02
* @description                  : Class for updating Is_Walmart_Subscription__c to false for migrated delivery passes
* @lastmodifiedBy				: Deepakshi Grover
* last modified date 			: 2024-08-02
**********************************************************************************/
public class ASDAC_DPWalmartSubscription implements Database.Batchable<sObject> {
    
    
    public String query = 'SELECT Id, Is_Walmart_Subscription__c FROM Asset ' +
                          'WHERE Is_Walmart_Subscription__c = true ' +
                          'AND CreatedBy.Name LIKE \'%Migration User%\' ' +
                          'AND CreatedDate = LAST_N_DAYS:2';

   
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }

    
    public void execute(Database.BatchableContext bc, List<Asset> lstAsset) {
      
        for (Asset asset : lstAsset) {
            asset.Is_Walmart_Subscription__c = false;
        }
        update lstAsset;
    }

    
    public void finish(Database.BatchableContext bc) {
        
        System.debug('Batch process completed successfully.');
    }
}