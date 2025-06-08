@isTest
public with sharing class ASDAC_UpdateCasePayoutStatusBatch_Test {
    private static final String[] PAYOUT_STATUS_PENDING_FAILURE = new String[]{System.Label.ASDAC_PayoutStatusPending.split(', ')[0], System.Label.ASDAC_PayoutStatusFailure.split(', ')[0]};

    @isTest
    static void testBatch_casePayoutStatusUpdation_success() {
        Account acc = ASDAC_TestDataUtility.createAccount(true);
        List<Case> cases = new List<Case>();
        for (Integer i = 0; i < 10; i++) {
            Case c = new Case(
                AccountId = acc.Id,
                ContactReasonLevel1__c = 'Payment & Refunds',
                ContactReasonLevel2__c = 'Manual Refund Processed',
                Origin = 'Phone',
                BusinessArea__c = 'George',
                Subject = 'Manual Payout',
                Description = 'Manual Payout Test',
                Status = ASDAC_GlobalConstants.STRING_STATUS_ASSIGNED,  
                Payout_Id__c = 'PayoutId' + i,
                PayoutStatus__c = (Math.Mod(i, 2) == 0) ? PAYOUT_STATUS_PENDING_FAILURE[0] : PAYOUT_STATUS_PENDING_FAILURE[1],
                WorkQueue__c = (Math.Mod(i, 2) == 0) ? System.Label.ASDAC_APIManualRefundPendingQueue : System.Label.ASDAC_APIManualRefundFailureQueue
            );
            cases.add(c);
        }
        insert cases;

        // Start test
        Test.startTest();     
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Create instance of the batch class
        ASDAC_UpdateCasePayoutStatusBatch batch = new ASDAC_UpdateCasePayoutStatusBatch();
        
        // Execute the batch
        Database.executeBatch(batch);
        
        // End test
        Test.stopTest();
        
        // Verify the results
        List<Case> updatedCases = [SELECT Id, PayoutStatus__c FROM Case WHERE PayoutStatus__c NOT IN :PAYOUT_STATUS_PENDING_FAILURE];     
        Assert.areEqual(10, updatedCases.size(), 'All cases are not updated');
    }
    
    // Mock HTTP Response Generator
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
        	res.setBody('{"statusCode":200,"strData":"{\\"status\\":\\"ACCOUNT_CREDITED\\"}"}');
        	res.setStatusCode(200);
        	return res;
        }
    }
}