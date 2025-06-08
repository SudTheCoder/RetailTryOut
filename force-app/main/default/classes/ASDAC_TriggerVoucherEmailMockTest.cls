public class ASDAC_TriggerVoucherEmailMockTest implements HttpCalloutMock {
	 public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
       String body ='{\n'+
            '"requestId": "97d4deb6-af9a-4345-a6c1-d8d08d947a75",\n'+
            '"errorcode": 0,\n'+
        '}\n';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(body);
        response.setStatusCode(202);
        return response; 
    }

}