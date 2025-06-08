/**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-09-22
* @Component Type               : Apex Class
* @component Name               : ASDAC_RSNullifyBatch
* @description                  : ASDAC-15557
* @Modified By                  : Niteesh Kumar
* @Modified Date		        : 2024-09-16
************************************************************************************/ 
public class ASDAC_RSNullifyBatch implements  Queueable, Database.AllowsCallouts{
        public Asset asst;
    public ASDAC_RSNullifyBatch(Asset asst){
        this.asst = asst;
    }
       public void execute(QueueableContext context) {
        Asset objAsset = this.asst;
            if(objAsset.Recurring_Slot_Template_Id__c != null){
            Boolean blnResponse = doCancellationCallout(objAsset.Recurring_Slot_Template_Id__c ,objAsset.Id);
                if(blnResponse){
                    objAsset.Recurring_Slot_Status__c = 'Cancelled';
                    objAsset.Is_1_skipped__c = false;
                    objAsset.Is_2_skipped__c = false;
                    objAsset.Is_3_skipped__c = false;
                    objAsset.Recurring_Slot_1__c = null;
                    objAsset.Recurring_Slot_Frequency__c =null;
                    objAsset.seq_counter__c =0;  
                    Update objAsset;
                }
            }
    }
    
    
   
    // Method to make a callout
    public static Boolean doCancellationCallout(String strTemplateId, Id strAssetId) {
        HttpRequest request = new HttpRequest();
        Boolean blnSuccess = false;
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('id',strTemplateId);
        gen.writeEndObject();
        String strRequestBody = gen.getAsString();
        
        ASDAC_Loyalty_base_urls__mdt urlRecurring = ASDAC_Loyalty_base_urls__mdt.getInstance('RecurringSlotCancellation');

        String strEndpoint = urlRecurring.Traget_endpoint__c;
        request.setEndpoint(strEndpoint);
        request.setMethod('PUT');
        request.setBody(strRequestBody);
        Http http = new Http();
        
        HttpResponse response = http.send(request);
        String responseBody = response.getBody();
        if (response.getStatusCode() == 200) {
            
            ResponseWrapper objResWrapper = (ResponseWrapper) JSON.deserialize(responseBody, ResponseWrapper.class);
            if(objResWrapper.success){
                blnSuccess = true;
            }else{
                blnSuccess = false;
            }
        }
        return blnSuccess;
    }
    
    public class ResponseWrapper {
        public Boolean success;
    }
    
}