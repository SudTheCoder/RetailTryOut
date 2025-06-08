/**********************************************************************************
 * @author                       : Deepakshi Grover
 * @date                         : 2023-03-17
 * @Component Type               : Apex Class
 * @component Name               : ASDAC_XMLCalloutMock
 * @description                  : ASDAC-8013 - GHS - DP SME - Auto Renewal
 * @Modified By                  : Deepakshi
 * @Modified Date		         : 2023-03-07
 ***************************************************************************************************/
@isTest
global class ASDAC_XMLCalloutMockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        
        // Create a dummy response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"data":{"status":"OK","message":"Auto Renewed"}}');
        res.setStatusCode(200);
        return res;
    }

}