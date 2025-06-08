/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-07-20
* @description                  : Class to send create recurring slot detail to Bringg via AIS 
* @lastmodifiedBy				: Deepakshi Grover
* last modified date 			: 2023-07-20
**********************************************************************************/
public class ASDAC_RSCreationBringg {
    
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-20
    * @Method Name                  : addCoupon
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/
    @InvocableMethod(label = 'Create Recurring Slot In Bringg')
    public static List<OutputWrapper> createRecurringSlot(List<InputVariables> assetsIdList) {
        List<OutputWrapper> outputList = new List<OutputWrapper>();
        
        OutputWrapper objOut = new OutputWrapper();
        JSONGenerator gen = JSON.createGenerator(true);
        if(string.isNotBlank(assetsIdList[0].strRecurringSlotId) && string.isNotBlank(assetsIdList[0].intFrequency) && string.isNotBlank(assetsIdList[0].recordId)){
            
            gen.writeStartObject();
            gen.writeStringField('task_external_id', assetsIdList[0].strRecurringSlotId);
            gen.writeNumberField('schedule_type', Integer.valueOf(assetsIdList[0].intFrequency));
            gen.writeEndObject();
            String strRequestBody = gen.getAsString();
            
            String recordId = assetsIdList[0].recordId; 
            objOut = doBringgCallout(strRequestBody, recordId);
            outputList.add(objOut);
            return outputList;
        } else{
            objOut.error = 'Error Occured';
            objOut.message = 'Asset Id/ Recurring Slot Id/ Frequency Cannot be null';
            outputList.add(objOut);
            return outputList;
        }
    }
    
    /**********************************************************************************
    * @author                       : Deepakshi Grover
    * @date                         : 2023-07-21
    * @Method Name                  : doBringgCallout
    * @Modified By                  : Deepakshi
    * @Modified Date		        : 2023-07-28
    **********************************************************************************/
    public static OutputWrapper doBringgCallout(String strRequestBody, String recordId) {
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        ASDAC_Loyalty_base_urls__mdt urlRecurring = ASDAC_Loyalty_base_urls__mdt.getInstance('RecurringSlotCreation');
        
        String strEndpoint = urlRecurring.Traget_endpoint__c;
        request.setEndpoint(strEndpoint);
        
        request.setBody(strRequestBody);
        Http http = new Http();
        
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        if (response.getStatusCode() == 200) {
            
            ResponseWrapper objResWrapper = (ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
            OutputWrapper objOutput = new OutputWrapper();
            objOutput.tempId = string.valueOf(objResWrapper.id);
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
        @InvocableVariable public String strRecurringSlotId; 
        @InvocableVariable public String intFrequency;
        @InvocableVariable public String recordId;
        @InvocableVariable public String accessToken;
    }
    
    public class OutputWrapper {
        @InvocableVariable public String tempId;
        @InvocableVariable public String error;
        @InvocableVariable public String message;
    }
    
    public class ResponseWrapper {
        public Boolean success;
        public Integer id;
    }
    
    public class ErrorResponseWrapper {
        public String path;
        public String error;
        public String message;
        public String status;
        public String timestamp;
    }
}