public with sharing class ASDAC_OrderHistoryService implements ASDAC_IntegrationServices{
    
    /**
* ****************************************************************************************************
* @param String requestType
* @description POST Callout to Stub Org Order History Data
* @return String JSON
* ****************************************************************************************************
*/           
    public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'SampleGetOrderListMock' LIMIT 1];
		return new ASDAC_IntegrationUtility.ResultWrapper(true, '', sr.Body.toString());
    }
    
    public static String createRequest(String reqkey){ 
        return null;
    }
    
    /**
* ****************************************************************************************************
* @param NA
* @param NA
* @description Request Wrapper class for Stub Demops
* @return NA
* ****************************************************************************************************
*/ 
    public class RequestWrapper {
        public String key;
        public String type;
        public String src;
        public Boolean disabled;
    }
}