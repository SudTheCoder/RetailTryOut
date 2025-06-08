public class ASDAC_DisableCustVoucherServiceMockTest implements HttpCalloutMock{
      public static Boolean returnError=false;
    
    public HttpResponse respond(HttpRequest request){
        
        
        String apiAuthorizationHeader = 'Bearer'+' '+'f1fY_SmhFU5NgfHgF9VzDyMkuA0';
        
        String body= '{\n'+
            '"enabled": false,\n'+
            '"merchant_id": "00032540",\n'+
            '"status": "issued",\n'+
            '}'; 
        
		HttpResponse response = new HttpResponse(); 
        
        response.setBody(body);
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setHeader('APIAuthorization', apiAuthorizationHeader);
        response.setHeader('Authorization', 'Basic c3RvcmVmcm9udDpkaXJlY3QxMjM0'); 
        if (returnError=true)
        {
            system.debug('returnError' +returnError);
            response.setStatusCode(425);
            response.setBody('{"error":"Disable failed", "message":"Retry later"}');
        }
      
        
        return response;
    }
    
   


}