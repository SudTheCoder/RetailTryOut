/**********************************************************************************
 * @author                       : Deepakshi Grover
 * @date                         : 2023-05-23
 * @Component Type               : Apex Class
 * @component Name               : ASDAC_AddCouponToWalletMockTest
 * @description                  : 
 * @Modified By                  : Deepakshi
 * @Modified Date		         : 2023-11-06
 ***************************************************************************************************/
@isTest
global class ASDAC_AddCouponToWalletMockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a dummy response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"accountId":"2046263687","walletId":"155703480","campaignId":"1526381","type":"ECOUPON","clientType":"DEFAULT","status":"ACTIVE","state":"DEFAULT","dates":{"start":"2023-02-17T10:10:00+00:00","end":"2023-04-30T22:59:00+00:00"},"meta":[],"dateCreated":"2023-05-23T10:45:22+00:00","lastUpdated":"2023-05-23T10:45:22+00:00","overrides":{"offer":{"reward":{"discountAmount":300}}},"balances":{"available":0,"refundable":0},"relationships":[],"mobileWallet":"https://demoapi.podifi.com/passbook/account/2046263687/760c73f53bc46da0e86ffdc09c4053818b747629ff0251ca22dcce1babd68ef1"}');
            res.setStatusCode(201);
        return res;
    }

}