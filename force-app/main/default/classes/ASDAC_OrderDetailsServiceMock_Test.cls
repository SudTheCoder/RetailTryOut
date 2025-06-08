@isTest
global with sharing class ASDAC_OrderDetailsServiceMock_Test implements HttpCalloutMock{
    
    global HttpResponse respond(HttpRequest req){
        
        StaticResource jsonListobj = [SELECT Id, Name, Body, Description FROM StaticResource WHERE Name = 'SampleGetOrderDetailsMock' LIMIT 1];
        Blob b = jsonListobj.Body;
        String content = b.tostring();  
        
        HttpResponse res = new HttpResponse();
        res.setBody(content);
        res.setStatusCode(400);
        return res;
    }
}