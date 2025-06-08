@isTest
private with sharing class ASDAC_GoodWillVoucherTest {
    
    @isTest
    static void testGetGoodwillVoucher() {
        // declaring walletId
        String walletId = '155819274';
        
        
        
        // Call the method
        test.startTest();
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new GoodWillVoucherMock());
        List<object> result = ASDAC_GoodWillVoucher.getGoodwillVoucher(walletId);
        
        test.stopTest();
    }
    

public class GoodWillVoucherMock implements HttpCalloutMock{
    
    public HttpResponse respond (HttpRequest request){
        String jsonString = '{"total": 2,"results": [{"accountId": "2048325004","walletId": "155819274","campaignId": "986712","type": "POINTS","clientType": null,"status": "ACTIVE","state": "DEFAULT","dates": {"start": "2023-05-24T07:28:23+00:00","end": "2038-01-19T03:14:07+00:00"},"meta": {"key1": "CampaignName:Goodwill Voucher, ReasonCode:creating new single user coupon code, Source:Prakash Dhanasekaran - Vendor"},"dateCreated": "2023-05-24T07:28:23+00:00","lastUpdated": "2023-05-24T07:28:23+00:00","overrides": [],"balances": {"current": 0,"usable": 0,"locked": 0,"lifetime": 0,"lifetimeSpend": 0,"lifetimeSpendValue": 0,"pending": 0}, "relationships": [],"mobileWallet": "https://demoapi.podifi.com/passbook/account/2048325004/e7b56b446df9e1dc0aa24dc2f9c887783bbffad74f8eafc1683140f14591a210"},{"accountId": "2050815768","walletId": "155819274","campaignId": "1526381","type": "ECOUPON","clientType": "DEFAULT","status": "ACTIVE","state": "DEFAULT","dates": {"start": "2023-02-17T10:10:00+00:00","end": "2023-04-30T22:59:00+00:00"},"meta": [],"dateCreated": "2023-05-25T12:38:05+00:00","lastUpdated": "2023-05-26T11:59:20+00:00","overrides": {"offer": {"reward": {"discountAmount": "20"}}},"balances": {"available": 0,"refundable": 0},"relationships": [],"mobileWallet": "https://demoapi.podifi.com/passbook/account/2050815768/00733bd113a1f4b1e58be1423fa479fbe3742707abfe85c9f5b4cdc7e812b684"}]}';
		

        System.debug(jsonString);
        
        
        String strHash = '985c17ab08a71a84b37a87c884902b504768465eaf08bf3030ad008aef0321e5';
        
        
        HttpResponse response = new httpResponse();
        
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('X-EES-AUTH-HASH', strHash);
        response.setStatusCode(200);
        response.setBody(jsonString);
        
        return response;
    }
    
}
}