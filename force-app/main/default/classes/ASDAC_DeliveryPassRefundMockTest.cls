@isTest
public with sharing class ASDAC_DeliveryPassRefundMockTest implements HttpCalloutMock {
    private String mockResponseBody;
    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"updateTime":"2024-04-08T12:04:43.574Z","updateUser":"LOYALTY","orgId":"ASDA","sellingChannel":"ASDA_GROCERIES","orderId":"R-240408120443443473","orderType":"ReturnOrder","orderCategory":"ReturnOrder","customerId":"003KH000001a6oXYAQ","partialFillAllowed":true,"orderDate":"2024-04-08T13:04:42Z","customFields":{"fraud":{"fraudBypass":true},"returnType":"Original","returnReason":"Delivery Pass Refund","returnNotes":"Customer cancelled the delivery pass within colling period."},"aggregatedState":{"details":[{"state":"CREATED","stateId":"1000","quantity":1}]},"createUser":"LOYALTY","createTime":"2024-04-08T12:04:43.574Z","billingCurrency":"GBP","orderTotals":{"subtotal":36,"tax":0,"charges":0,"discounts":0,"totalAmount":36},"associationDetails":[{"orgId":"ASDA","sellingChannel":"ASDA_GROCERIES","associationType":"SalesOrder","orderId":"10000000014975"}],"addressInfo":[],"refundPaymentMethod":"ORIGINAL","refundStatus":"LATER","orderLines":[{"updateTime":"2024-04-08T12:04:43.574Z","updateUser":"LOYALTY","orderLineId":1,"orderLineType":"ASDADelivery","fulfillmentType":"DIGITAL","fulfillmentService":"STANDARD","quantity":1,"productId":"910003240607","uom":"EACH","stateTransitionFlowId":"GROCERY_RETURN_ORDER_LINE_STATE_TRANSITION","customFields":{"fraud":{"fraudBypass":true},"returnType":"Original","returnReason":"Delivery Pass Refund","returnNotes":"Customer cancelled the delivery pass within colling period."},"aggregatedState":{"workflowIdByState":{"CREATED":"GROCERY_RETURN_PROCESS_WORKFLOW_27_MAR"},"details":[{"state":"CREATED","stateId":"1000","event":"CREATE_RETURN","quantity":1,"correlationIdQuantityMap":{"OMS1712577883354":{"GROCERY_RETURN_PROCESS_WORKFLOW_27_MAR":1}}}]},"stateTransitions":{"CREATED":[{"id":"648501cf-b0d7-454d-9ae1-a1a346c1db5f","event":"CREATE_RETURN","previousQuantity":0,"newQuantity":1,"nextPossibleEvents":["CANCEL","BYPASS","REVIEW","ACCEPT"],"stateUpdatedTime":"2024-04-08T12:04:43Z","correlationId":"OMS1712577883354","stateId":"1000"}]},"productDescription":"Anytime Delivery Pass - 6 months (6-monthly payment)","reasonCode":"Delivery Pass Refund","workFlowId":"GROCERY_RETURN_PROCESS_WORKFLOW_27_MAR","prices":[{"value":36,"name":"Unit Price","useForTotals":true}],"lineTotals":{"subtotal":36,"tax":0,"charges":0,"discounts":0,"totalAmount":36},"isRefundable":true,"associationDetails":[{"associationType":"SalesOrder","associatedLineId":1}],"addressInfo":[]}]}');
        response.setStatusCode(201);
		mockResponseBody = response.getBody();
        return response;
    }
    
    public String getMockResponseBody() {
        return mockResponseBody;
    }
}