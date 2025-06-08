/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-05-17
* @Component Type               : Apex Class
* @component Name               : ASDAC_HashTokenGenerator
* @description                  : ASDAC-10298
* @Modified By                  : Deepakshi/Niteesh
* @Modified Date		         : 2023-05-23
**********************************************************************************/

public with sharing class ASDAC_HashTokenGenerator {
    
    
    /**********************************************************************************
    * @author                       : Niteesh Kumar
    * @date                         : 2023-09-11
    * @Method Name                  :  sendAISRequest- To incorporate PS AIS Endpoint
    * @Modified By                  : Niteesh
    * @Modified Date		        : 
    **********************************************************************************/
    public static HttpRequest sendAISRequest(String payload, String strMethod,String strURL){
        String endpoint = 'callout:GHSVoucherAPI/external/eagleeye/v1'+strURL; 
        Http http = new Http();
        HttpRequest httpRequest = new HttpRequest();
        
        httpRequest.setMethod(strMethod);
        if(strMethod == 'POST'){
            httpRequest.setBody(payload);
        }
        
        httpRequest.setEndpoint(endpoint);
        
        return httpRequest;        
    }
}