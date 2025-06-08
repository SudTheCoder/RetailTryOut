/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-07-22
* @description                  : Class to send cancel recurring slot detail to Bringg via AIS 
* @lastmodifiedBy				: Deepakshi Grover
* last modified date 			: 2023-07-29
**********************************************************************************/
public class ASDAC_RSCancellationSync {
    
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-20
    * @Method Name                  : cancelRecurringSlot
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/
    @InvocableMethod(label = 'Cancel Recurring Slots')
    public static List<OutputWrapper> cancelRecurringSlot(List<InputVariables> assetsIdList) {
        List<OutputWrapper> outputList = new List<OutputWrapper>();
        OutputWrapper objOut = new OutputWrapper();
        JSONGenerator gen = JSON.createGenerator(true);
        
        if(string.isNotBlank(assetsIdList[0].strTemplateId) && string.isNotBlank(assetsIdList[0].strAssetId) && string.isNotBlank(assetsIdList[0].strRSStatus)){
            gen.writeStartObject();
            gen.writeStringField('id', assetsIdList[0].strTemplateId);
            gen.writeEndObject();
            String strRequestBody = gen.getAsString();
            objOut = doCancellationCallout(strRequestBody);
            outputList.add(objOut);
            return outputList;
        } else{
            objOut.error = 'Error Occured';
            objOut.message = 'Asset Id/ Recurring Slot Status/ Template Id Cannot be null';
            objOut.success = false;
            outputList.add(objOut);
            return outputList;
        }  
    }
    
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-20
    * @Method Name                  : doCancellationCallout
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/    
    public static OutputWrapper doCancellationCallout(String strRequestBody) {
        HttpRequest request = new HttpRequest();
        request.setMethod('PUT');
        ASDAC_Loyalty_base_urls__mdt urlRecurring = ASDAC_Loyalty_base_urls__mdt.getInstance('RecurringSlotCancellation');
		String strEndpoint = urlRecurring.Traget_endpoint__c;
        request.setEndpoint(strEndpoint);
        request.setBody(strRequestBody);
        Http http = new Http();
        
        HttpResponse response = http.send(request);
        
        String responseBody = response.getBody();
        
        if (response.getStatusCode() == 200) {
            
            ResponseWrapper objResWrapper = (ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
            OutputWrapper objOutput = new OutputWrapper();
            if(objResWrapper.success){
                objOutput.success = true;
            }
            return objOutput;
            
        } else {
            ErrorResponseWrapper objErrWrapper = (ErrorResponseWrapper) JSON.deserialize(responseBody, ErrorResponseWrapper.class);
            OutputWrapper objOutput = new OutputWrapper();
            objOutput.error = string.valueOf(objErrWrapper.error);
            objOutput.message = string.valueOf(objErrWrapper.message);
            
            return objOutput;
        }
    }
    
    public class InputVariables {
        @InvocableVariable public String strTemplateId; 
        @InvocableVariable public String strAssetId; 
        @InvocableVariable public String strRSStatus; 
        @InvocableVariable public String accessToken;
    }
    
    public class OutputWrapper {
        @InvocableVariable public String error;
        @InvocableVariable public String message;
        @InvocableVariable public Boolean success;
    }
    
    public class ResponseWrapper {
        public Boolean success;
    }
    
    public class ErrorResponseWrapper {
        public String path;
        public String error;
        public String message;
        public String status;
        public String timestamp;
    }
}