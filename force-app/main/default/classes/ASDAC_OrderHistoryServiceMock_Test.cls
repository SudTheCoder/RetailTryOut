@isTest
global with sharing class ASDAC_OrderHistoryServiceMock_Test implements HttpCalloutMock{
    
    global HttpResponse respond(HttpRequest req){
        
        StaticResource jsonListobj = [SELECT Id, Name, Body, Description FROM StaticResource WHERE Name = 'SampleGetOrderListMock' LIMIT 1];
        Blob b = jsonListobj.Body;
        String content = b.tostring();  
        
        HttpResponse res = new HttpResponse();
        res.setBody(content); 
        res.setStatusCode(200);
        return res;
    }
}