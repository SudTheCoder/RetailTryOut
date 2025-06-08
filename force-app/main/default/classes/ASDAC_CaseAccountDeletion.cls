public with sharing class ASDAC_CaseAccountDeletion {
    @InvocableMethod(label='Process Case for Account Deletion Approval')
    public static List<Results> processCases(List<Request> request) {
        List<Results> results = new List<Results>();
        if(!request.isEmpty()){
            List<Case> cases = [SELECT Id, AccountId, ContactId, Account.Loginid__c, Account.PersonContactId FROM Case WHERE Id IN :request.get(0).cases];
            if(!cases.isEmpty()){
                for (Case c : cases) {
                    ASDAC_MockApiService.ApiCallParams params = new ASDAC_MockApiService.ApiCallParams(c.AccountId, c.ContactId, c.Account.Loginid__c, c.Account.PersonContactId);
            // Call mock API service for testing
                    Results result = new Results();
                    result.statusCode = ASDAC_MockApiService.makeAPICall(params);
                    results.add(result);
                }
            }
        }
        return results;
    }
    public class Request{
        @InvocableVariable
        public List<Case> cases;
    }
    public class Results {
        @InvocableVariable
        public Integer statusCode;
    }
}