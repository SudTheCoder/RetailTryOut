public with sharing class ASDAC_CaseService implements ASDAC_CustomSearchInterface {
    
    public List<SObject> getLookupRecords(String searchParametersJsonString){
        Map<String,Object> searchParameters = (Map<String,Object>)json.deserializeUntyped(searchParametersJsonString);
        String recordId;
        string businessArea;
        string taskType;
        string manualRefundPayoutQueue;
        string searchTerm = (string)searchParameters.get('searchTerm');
        Boolean isIssueEvoucher = (Boolean)searchParameters.get('isIssueEvoucher');   
        recordId = (String)searchParameters.get('recordId');
        businessArea = (String)searchParameters.get('businessArea');
        taskType = (String)searchParameters.get('taskType');
        manualRefundPayoutQueue = System.Label.ASDAC_APIManualRefundQueue;
        String queryCase = 'SELECT Id, AccountId, CreatedDate, Status, ContactId ,Contact.Name, Subject, CaseNumber FROM Case WHERE (ContactId = : recordId AND BusinessArea__c = : businessArea)';
        List<Case> casesToReturn = new List<Case>();
        if(isIssueEvoucher){
            queryCase += ' AND VoucherCode__c = NULL';
        }
        if(taskType == System.Label.ASDAC_ManualRefundTaskLabel){
            queryCase += ' AND Amount__c = NULL AND ReasonCode__c = NULL AND WorkQueue__c = : manualRefundPayoutQueue';
        }
        if(String.isNotBlank(searchTerm)) {
            queryCase += ' AND (CaseNumber = : searchTerm)'; 
        }
        queryCase += ' WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC';
        try {
            casesToReturn = database.query(String.escapeSingleQuotes(queryCase));
        } catch (Exception e) {
            // Throw exception on to caller
            throw e;
        } 
        return casesToReturn;      
    }
}