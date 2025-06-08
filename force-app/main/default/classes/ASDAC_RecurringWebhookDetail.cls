/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-03-06
* @description                  : Webservice class to handle skipping detail coming from bringg via AIS
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                06-Mar-2023      Created the class
***************************************************************************************************/
@RestResource(urlMapping='/api/incoming/pushSkippingSlot/*')
global with sharing class ASDAC_RecurringWebhookDetail {
    
    /******************************************************************************************************
* @param : Payload structure
* @description : Post call for third party system to consume our API
* @return success or error response
* *****************************************************************************************************/
    @httpPost
    global  static void handleSkippingslotWebhook(){
        String customerId; 
        String skipSlotDate; 
        Integer skippingreasonId;
        
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Boolean recurringSlotDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('RecurringSlotSkippingEnablement').ASDAC_LoyaltySwitch__c;
        if(!recurringSlotDisable){
            try{
                String payload =   request.requestBody.toString();
                Map<String,Object> result  = (Map<String,Object>)json.deserializeUntyped(payload);
                
                Map<String,Object> task = (Map<String,Object>)result.get('task');
                
                List<Object> waypoints = (List<Object>)task.get('way_points'); 
                
                Map<String,Object> taskCancellationReason = (Map<String,Object>)task.get('task_cancellation_reason');
                Map<String,Object> reason = (Map<String,Object>)taskCancellationReason.get('reason_to_cancel_task');
                skippingreasonId = Integer.valueOf(reason.get('id'));
                
                String templateId = String.ValueOf(task.get('recurrent_task_template_id'));
                Map<String,Object> customer = (Map<String,Object>)task.get('customer');
                customerId = String.valueOf(customer.get('external_id'));
                for(Object obj:waypoints){
                    Map<String,Object> val = (Map<String,Object>)obj;
                    skipSlotDate = val.get('position')==2 ? val.get('no_later_than').toString():null;
                }
                
                ASDAC_RecurringWebhookDetailHelper.recurringSlotHelper(customerId,skipSlotDate,skippingreasonId,templateId);
                response.statusCode = 200;
                response.responseBody = Blob.valueOf(Json.serialize(new SFDCResponse('Success','Processed Successfully')));    
                
            }catch(Exception e){
                ASDAC_Logger.logException(e, ASDAC_GlobalConstants.STRING_LOYALTY, 'skipping detail issue', 'ASDAC_RecurringWebhookDetail');
                ASDAC_Logger.writeLogsToDatabase();
                response.statusCode = 400;
                response.responseBody = Blob.valueOf(Json.serialize(new SFDCResponse('Error',e.getMessage()))); 
            }
        }
    }
    
    public class SFDCResponse{
        String response;
        String message;
        public SFDCResponse(String response, string message){
            this.response= response;
            this.message = message;
        }
    }
}