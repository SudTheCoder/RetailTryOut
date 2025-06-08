public class ASDAC_AuthorizeSFCCForVoucherMockTest implements HttpCalloutMock {
	public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
       String body = '{\n "access_token": "f1fY_SmhFU5NgfHgF9VzDyMkuA0",\n'+
    					'"token_type": "Bearer"\n'+
      					'}';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(200);
        return response; 
    }
}