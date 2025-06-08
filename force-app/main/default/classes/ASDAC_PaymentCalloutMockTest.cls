@isTest
global class ASDAC_PaymentCalloutMockTest implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type','application/json');
        res.setBody('{"creationOutput":{"externalReference":"ec57eb00-e295-41f9-8a02-12b4c3465e9b","token":"ec57eb00-e295-41f9-8a02-12b4c3465e9b" },"payment":{"paymentOutput": { "amountOfMoney": { "amount": 91800,"currencyCode": "EUR" },"references": {"merchantReference": "S2S_TOKEN-1678979906"},"acquiredAmount": {"amount": 91800,"currencyCode": "EUR"},"customer": {"device": {"ipAddressCountryCode": "99"}},"cardPaymentMethodSpecificOutput": {"paymentProductId": 1,"authorisationCode": "1403866403","card": {"cardNumber": "************2022","expiryDate": "1238","bin": "487497", "countryCode": "BE" }, "fraudResults": { "fraudServiceResult": "no-advice","avsResult": "U","cvvResult": "0"},"threeDSecureResults": {"eci": "9","xid": "MzI2MzM1Njk0OA=="},"token": "ec57eb00-e295-41f9-8a02-12b4c3465e9b"},"paymentMethod": "card"},"status": "PENDING_CAPTURE","statusOutput": {"isCancellable": false, "statusCategory": "COMPLETED", "statusCode": 9, "isAuthorized": false, "isRefundable": true},"id": "3263356948_0"}}');
        res.setStatusCode(201);
        return res;
    }
}