/**********************************************************************************
* @author                       : Kartikey Papnai
* @date                         : 05/05/2023
* @description                  : ASDAC-9079 - Rel C - Geo - GV - CCA UI API integration - View Customer's Voucher History ( By CRM ID)
*@Modified By 					: Niteeh Kumar (20-07-2023)
**********************************************************************************/
public with sharing class ASDAC_CustomerVourcherHistoryCRM {
    
    @AuraEnabled(cacheable=true)
    public Static List<object> getVoucherHistoryServicedata(String accId){
        try {
            boolean  geoVoucherReleaseC=  ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('ASDAC_George_Voucher_CRMID').ASDAC_LoyaltySwitch__c;
            Account accountCRM = [select personContactId,Loginid__c from account where  id =:accId limit 1];
            Merkel_AuthVal__mdt mc = Merkel_AuthVal__mdt.getInstance('getvouchercrm');
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(mc.eVoucherEndPointURL__c);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            String searchVoucherPayload;
            if(geoVoucherReleaseC){
                searchVoucherPayload = jsonBodyByCRMIdSearch(accountCRM.personContactId);
            }else {
                searchVoucherPayload = jsonBodyByEmailSearch(accountCRM.Loginid__c);
            }
            
            //setting the above created body
            request.setBody(searchVoucherPayload);
            
            HttpResponse response = http.send(request);
            
            Map<String,Object> jsonMap = (Map<String,Object>)json.deserializeUntyped(response.getBody());
            List<Object> georgeVoucherSearchResponse =  constractGeorgeVoucherSearchData(jsonMap);
            return georgeVoucherSearchResponse;
        } catch (Exception e) {
            System.debug('Error fetching voucher history: ' + e.getMessage());
            return null;
        }
        
    }
    public static String jsonBodyByCRMIdSearch(String crmId){
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeFieldName('query'); 
        gen.writeStartObject(); 
        gen.writeFieldName('bool_query'); 
        gen.writeStartObject();
        gen.writeFieldName('must');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeFieldName('text_query');
        gen.writeStartObject();
        gen.writeFieldName('fields');
        gen.writeStartArray(); 
        gen.writeString('c_crm_id');
        gen.writeEndArray();
        gen.writeStringField('search_phrase', crmId);
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeStringField('select','(**)');
        gen.writeNumberField('start',0);
        gen.writeNumberField('count',200);
        gen.writeFieldName('sorts');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('field', 'creation_date');
        gen.writeStringField('sort_order', 'desc');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonReq = gen.getAsString(); 
        System.debug('JsonReq'+jsonReq);
        return jsonReq;
    }
    
    
    //Create Search request payload for George
    public static String jsonBodyByEmailSearch(String customerEmail){
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject(); 
        gen.writeFieldName('query'); 
        gen.writeStartObject(); 
        gen.writeFieldName('text_query'); 
        gen.writeStartObject();
        gen.writeFieldName('fields');
        gen.writeStartArray(); 
        gen.writeString('recipient_email');
        gen.writeEndArray();
        gen.writeStringField('search_phrase', customerEmail);
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeStringField('select','(**)');
        gen.writeNumberField('start',0);
        gen.writeNumberField('count',200);
        gen.writeFieldName('sorts');
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('field', 'creation_date');
        gen.writeStringField('sort_order', 'desc');
        gen.writeEndObject();
        gen.writeEndArray();
        gen.writeEndObject(); 
        
        String jsonReq = gen.getAsString(); 
        System.debug('JsonReq'+jsonReq);
        return jsonReq;
    }
    
    //Constract resonse value to show in UI
    public static List<Object> constractGeorgeVoucherSearchData(Map<String,Object> searchRawResponse){
        List<ASDAC_CustomerVourcherHistoryCRM.Responsevalue> responsevaluelist = new List<ASDAC_CustomerVourcherHistoryCRM.Responsevalue>();
        //List of hits received from the response
        system.debug('searchRawResponse : '+searchRawResponse);
        List<Object> hits = (List<Object>) searchRawResponse.get('hits');
        system.debug('hits: '+hits);
        for (Object hit : hits) {
            Map<String, Object> hitMap = (Map<String, Object>) hit;
            Map<String, Object> amountMap = (Map<String, Object>) hitMap.get('amount');
            boolean isNotVoucherData = hitMap.containsKey('c_isGiftCard') || hitMap.containsKey('c_asdaStars'); //INC0283408 changes to add asdastars voucher
            if(!isNotVoucherData && hitMap.get('enabled')== True && Date.valueOf(String.valueOf(hitMap.get('c_expiryDate'))) >= date.today() && (hitMap.get('status')=='issued' || hitMap.get('status')=='partially_redeemed')){
                Map<String,Object> dataconstract = new Map<String,Object>();
                system.debug(hitMap);
                dataconstract.put('description',hitMap.get('description'));
                dataconstract.put('code',hitMap.get('masked_gift_certificate_code'));
                dataconstract.put('amountValue',amountMap.get('value'));
                dataconstract.put('status',hitmap.get('status'));
                dataconstract.put('enabled',hitMap.get('enabled'));
                dataconstract.put('merchantId',hitMap.get('merchant_id'));
                
                //Formatting creation date into proper date Time
                String issueDate = (String)hitMap.get('creation_date');
                DateTime issueDateInstant = DateTime.valueOfGmt(issueDate.replace('T', ' ').substringBefore('.'));
                String formattedIssueDate = issueDateInstant.format('dd MMMM yyyy, EE hh:mm a', 'Europe/London');
                dataconstract.put('issueDate',formattedIssueDate);
                //Formatting Expiry date into proper date Time
                String expiryDate = (String)hitMap.get('c_expiryDate');
                DateTime expiryDateInstant = DateTime.valueOfGmt(expiryDate.replace('T', ' ').substringBefore('.'));
                String formattedExpiryDate = expiryDateInstant.format('dd MMMM yyyy, EE hh:mm a', 'Europe/London');
                dataconstract.put('expiryDate',formattedExpiryDate);
                
                
                String issued = getStatus(String.valueOf(hitMap.get('status')));
                String type =  getSender(String.valueOf(hitMap.get('sender_name')));
                dataconstract.put('type',type);
                dataconstract.put('redeemed',issued);
                
                responsevaluelist.add( new Responsevalue(dataconstract));
            }
        }
        System.debug('List of Data :'+responsevaluelist);
        
        return responsevaluelist;
    }
    
    //Helper class to get Status 
    public static String getStatus(String status){
        String s = status =='issued'?'No':'Yes';
       return s;
    }
    //Healper class for get Sender
      public static String getSender(String sender){
          String sd = sender =='OMS'?'Refund Voucher':'Goodwill Voucher';
        return sd;
    }
    //innser class for wrapping the response into MAP
    public class Responsevalue{
        @AuraEnabled public string type{get;set;}
        @AuraEnabled public string code{get;set;}
        @AuraEnabled public String issueDate{get;set;}
        @AuraEnabled public String expiryDate{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public Boolean enabled;
        @AuraEnabled public String merchantId {get;set;}
        @AuraEnabled public String redeemed;
        @AuraEnabled public String sender_name;
        @AuraEnabled public String description{get;set;}
        @AuraEnabled public Decimal amountValue{get;set;}
        
        public responsevalue(Map<String,Object> dataconstract){
            this.type = String.valueOf(dataconstract.get('type'));
            this.code = String.valueOf(dataconstract.get('code'));
            this.issueDate = String.valueOf(dataconstract.get('issueDate'));
            this.expiryDate = String.valueOf(dataconstract.get('expiryDate')) ;
            this.status = String.valueOf(dataconstract.get('status')) ;
            this.enabled = Boolean.valueOf(dataconstract.get('enabled')) ;
            this.merchantId = String.valueOf(dataconstract.get('merchantId'));
            this.redeemed = String.valueOf(dataconstract.get('redeemed'));
            this.sender_name = String.valueOf(dataconstract.get('sender_name'));
            this.amountValue = Decimal.valueOf(String.valueOf(dataconstract.get('amountValue')));
            this.description = String.valueOf(dataconstract.get('description'));
        }
    }
}