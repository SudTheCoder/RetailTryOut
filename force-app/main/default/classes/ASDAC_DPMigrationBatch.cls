/************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2024-06-20
* @description                  : ASDAC-20989 One time job for updating has_active_dp and has_expired_dp for migrated subscriptions
**********************************************************************************/

public with sharing class ASDAC_DPMigrationBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            Select id, status,Contactid,createdby.name,IsMigratedSubscription__c,Contact.Has_Active_Pass__c, Contact.Has_Expired_Pass__c,CreatedDate from Asset
            WHERE IsMigratedSubscription__c = true AND createdby.name LIKE '%Migration User%' AND CreatedDate >= LAST_N_DAYS:2
               AND (status = 'Active' OR status = 'Expired' OR status = 'Cancelled')
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Asset> lstAsset) {
       
        Map<Id, Boolean> contactHasActivePassMap = new Map<Id, Boolean>();
        Map<Id, Boolean> contactHasExpiredPassMap = new Map<Id, Boolean>();
        
        Set<Id> contactIds = new Set<Id>();
        
        for (Asset asset : lstAsset) {
            if (asset.ContactId != null) {
                contactIds.add(asset.ContactId);
                if (asset.status == 'Active') {
                    contactHasActivePassMap.put(asset.ContactId, true);
                } else if (asset.status == 'Expired' || asset.status == 'Cancelled') {
                    contactHasExpiredPassMap.put(asset.ContactId, true);
                }
            }
        }
        
        List<Contact> contactsToUpdate = [
            SELECT Id, Has_Active_Pass__c, Has_Expired_Pass__c
            FROM Contact
            WHERE Id IN :contactIds
        ];
        
		List<Contact> setUpdatedContacts = new List<Contact>();
        for (Contact con : contactsToUpdate) {
            if (contactHasActivePassMap.containsKey(con.Id)) {
                con.Has_Active_Pass__c = true;
            }
            if (contactHasExpiredPassMap.containsKey(con.Id)) {
                con.Has_Expired_Pass__c = true;
            }
			setUpdatedContacts.add(con);
        }
		
        
        update setUpdatedContacts;
    }

    public void finish(Database.BatchableContext bc) {
    }
}