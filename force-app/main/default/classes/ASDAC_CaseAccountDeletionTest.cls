@isTest
public with sharing class ASDAC_CaseAccountDeletionTest {

    @isTest
    static void testProcessCases() {
        List<Account> lstAccount = ASDAC_TestDataUtility.createPersonAccounts(1,true);
        List<Case> lstCase = ASDAC_TestDataUtility.createCases(1, true, 'CustomerSupport', lstAccount[0].Id);

        // Prepare the request
        ASDAC_CaseAccountDeletion.Request req = new ASDAC_CaseAccountDeletion.Request();
        List<ASDAC_CaseAccountDeletion.Results> res = new List<ASDAC_CaseAccountDeletion.Results>();
        req.cases = new List<Case>{ lstCase[0] };
        
        // Set mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Call the method to be tested
        Test.startTest();
        res = ASDAC_CaseAccountDeletion.processCases(new List<ASDAC_CaseAccountDeletion.Request>{ req });
        Test.stopTest();

        // Assertions
        System.assertEquals(true, res.size()>0);
    }

    // Nested class for mocking HTTP responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"status": "success"}');
            res.setStatusCode(200);
            return res;
        }
    }
}