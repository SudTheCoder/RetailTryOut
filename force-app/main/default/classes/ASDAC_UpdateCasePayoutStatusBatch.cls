/**********************************************************************************
* @Component Type               : Apex Class
* @Component Name               : ASDAC_UpdateCasePayoutStatusBatch
* @description                  : Batch class to update payout status using Worldline API
************************************************************************************/ 
public with sharing class ASDAC_UpdateCasePayoutStatusBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {

    private static final String[] PAYOUT_STATUS_PAID = new String[]{System.Label.ASDAC_PayoutStatusSuccess, null};
    private static final String[] WORK_QUEUE_REFUND_OUTSTANDING = new String[]{System.Label.ASDAC_APIManualRefundPendingQueue, System.Label.ASDAC_APIManualRefundFailureQueue};
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, BusinessArea__c, Payout_Id__c
            FROM Case
            WHERE PayoutStatus__c NOT IN :PAYOUT_STATUS_PAID
            AND WorkQueue__c IN :WORK_QUEUE_REFUND_OUTSTANDING
        ]);
    }

    /******************************************************************************************************
    * @description Execute method to process each batch of cases and update their payout status.
    * @param bc - Batchable context.
    * @param caseList - List of Case records to process.
    ******************************************************************************************************/
    public void execute(Database.BatchableContext bc, List<Case> caseList) {
        for (Case caseRecord : caseList) {
            try {
                // Create the payload for the API callout
                ASDAC_ManualRefundRequestController.DetailsWrapper requestDetails = new ASDAC_ManualRefundRequestController.DetailsWrapper();
                requestDetails.recordId = caseRecord.Id;
                requestDetails.businessArea = caseRecord.BusinessArea__c;
				requestDetails.payoutID = caseRecord.Payout_Id__c;
                requestDetails.methodType = 'GET';
                String requestBody = JSON.serialize(requestDetails);

                // Perform the API callout
                String payoutStatus = getPayoutStatus(requestBody);
				caseRecord.PayoutStatus__c = payoutStatus;
                      
            } catch (DmlException e) {
                if (e.getDmlType(0) == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION) {
                    System.debug('Field Filter Validation Exception for Case ID: ' + caseRecord.Id + ' - ' + e.getMessage());
                    continue;
                } 
            }
        }
			
        // Update cases with payout status
        update caseList;
    }
		
     /******************************************************************************************************
    * @description Finish method for post-processing or logging after batch job completes.
    * @param bc - Batchable context.
    ******************************************************************************************************/
    public void finish(Database.BatchableContext bc) {
    }

    public static String getPayoutStatus(String requestBody)
    {
        String response = ASDAC_ManualRefundRequestController.doManualRefundCallout(requestBody);
        String payoutStatus;
        if (response != null) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
            if ((Integer) responseMap.get('statusCode') == 200) {
                Map<String, Object> responseData = responseMap.get('strData') != null ? (Map<String, Object>) JSON.deserializeUntyped((String) responseMap.get('strData')) : null;
                if (responseData != null) {
                    payoutStatus = (String) responseData.get('status');
                }
            }
        }  
        return payoutStatus;			
    }
}