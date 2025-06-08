/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-10-10
* @description                  : Test Class for ASDAC_RSAccessToken 
* @lastmodifiedBy				: Deepakshi Grover
* last modified date 			: 2023-10-10
**********************************************************************************/
public class ASDAC_RSAccessToken {
    @InvocableMethod(label = 'Get Access Token')
    public static List<OutputWrapper> getAccessToken() {
        
        try{
            String payLoad = '{"Name":"test"}';
            System.debug(payLoad);
			String endPoint= 'worldlinePaymentAuth/v2';
            Http tokenHttp = new Http();
            HttpRequest tokenRequest = new HttpRequest();
            tokenRequest.setMethod('GET');
           
            
            tokenRequest.setEndpoint(endpoint);
            tokenRequest.setBody(payLoad);
            tokenRequest.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            HttpResponse tokenResponse = tokenHttp.send(tokenRequest);
            Map<String,Object> result = (Map<String,Object>)json.deserializeUntyped(tokenResponse.getBody());
            List<OutputWrapper> lstOutput = new List<OutputWrapper>();
            OutputWrapper objOutput = new OutputWrapper();
            objOutput.access_token = String.valueOf(result.get('access_token'));
            lstOutput.add(objOutput);
            return lstOutput;
        }catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getstacktracestring());
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_LOYALTY, 'Token issue', 'ASDAC_RSAccessToken');
			ASDAC_Logger.writeLogsToDatabase();
            
            return null;
        }
    }
    
    public class OutputWrapper {
        @InvocableVariable public String access_token;
    }
    
    public class InputVariables {
        @InvocableVariable public String strRecurring; 
    }
}