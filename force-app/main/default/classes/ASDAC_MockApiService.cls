public class ASDAC_MockApiService {
   @AuraEnabled
    public static Integer makeAPICall(ApiCallParams params) {
        // Construct the request body as JSON
        String correlationId = generateGuid();
        Map<String, Object> requestBody = new Map<String, Object>();
        requestBody.put('crmPersonId', params.personContactId);
        requestBody.put('crmAccountId', params.accountId);
        requestBody.put('LoginId', params.loginId);
        requestBody.put('requestType', 'Adhoc');

        String jsonBody = JSON.serialize(requestBody);

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:NC_Adhoc_Account_Deletion'); // Use the Named Credential
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('x-correlation-id',correlationId);
        req.setTimeout(60000);
        req.setBody(jsonBody);

        Http http = new Http();
        HttpResponse res = http.send(req);
        
        return res.getStatusCode();
      
    }
    public static String generateGuid() {
      Blob aesKey = Crypto.generateAesKey(128);
		String hexKey = EncodingUtil.convertToHex(aesKey);
		List<String> segments = new List<String>();

		segments.add(hexKey.substring(0, 8));
		segments.add(hexKey.substring(8, 12));
		segments.add(hexKey.substring(12, 16));
		segments.add(hexKey.substring(20));
		return String.join(segments, '-');
    }
    public class ApiCallParams {
       public String accountId;
       public String contactId;
       public String loginId;
       public String personContactId;

       public ApiCallParams(String accountId, String contactId, String loginId, String personContactId) {
           this.accountId = accountId;
           this.contactId = contactId;
           this.loginId = loginId;
           this.personContactId = personContactId;
       }
   }
     
}