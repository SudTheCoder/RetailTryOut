/**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 24/02/2023
* @description                  : ASDAC-6277 - Rel B - Geo - GV - CCA UI API integration - View Customer's Voucher History

**********************************************************************************/
public with Sharing class ASDAC_CustomerVoucherHistoryService  { 
    
    @AuraEnabled(cacheable=true)
    public Static List <object> getVoucherHistoryServicedata(String access_token, String accId){
        
        List<ASDAC_CustomerVoucherHistoryService.Responsevalue> responsevaluelist = new List<ASDAC_CustomerVoucherHistoryService.Responsevalue>();
        String accountEmail = [select personemail from account where  id =:accId limit 1].PersonEmail;
        Merkel_AuthVal__mdt mc = Merkel_AuthVal__mdt.getInstance('voucherCodeUpdationDetail');
        String apiAuthorizationHeader = 'Bearer'+ ' ' + access_token;
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(mc.eVoucherEndPointURL__c);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', apiAuthorizationHeader); 
        //Create body
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
        gen.writeStringField('search_phrase', accountEmail);
        gen.writeEndObject();
        gen.writeEndObject();
        gen.writeStringField('select','(**)');
        gen.writeEndObject(); 
        
        String jsonReq = gen.getAsString(); 
        //setting the above created body
        request.setBody(jsonReq);
        HttpResponse response = http.send(request);
        Map<String,Object> jsonMap = (Map<String,Object>)json.deserializeUntyped(response.getBody());
        
        //List of hits received from the response
        List<Object> hits = (List<Object>) jsonMap.get('hits');
        for (Object hit : hits) {
            Map<String, Object> hitMap = (Map<String, Object>) hit;
            Map<String, Object> balanceMap = (Map<String, Object>) hitMap.get('balance');
             
            if(hitMap.get('enabled')== True && (hitMap.get('status')=='issued' || hitMap.get('status')=='partially_redeemed' || hitMap.get('status')=='pending')){
                Map<String,Object> dataconstract = new Map<String,Object>();
                dataconstract.put('code',hitMap.get('masked_gift_certificate_code'));
               	dataconstract.put('balanceValue',balanceMap.get('value'));
                dataconstract.put('status',hitmap.get('status'));
                dataconstract.put('enabled',hitMap.get('enabled'));
                dataconstract.put('merchantId',hitMap.get('merchant_id'));
                
                //Formatting creation date into proper date Time
                String issueDate = (String)hitMap.get('creation_date');
                String formattedIssueDate = ASDAC_OrderUtility.convertStringToDateTimeString(issueDate);
                dataconstract.put('issueDate',formattedIssueDate);
                
                //Formatting Expiry date into proper date Time
                String expiryDate = (String)hitMap.get('c_expiryDate');
                String formattedExpiryDate = ASDAC_OrderUtility.convertStringToDateTimeString(expiryDate);
                dataconstract.put('expiryDate',formattedExpiryDate);
                
                if(hitMap.get('status')=='issued'){
                    dataconstract.put('redeemed','No');
                }
                else {
                    dataconstract.put('redeemed','Yes');
                }
                if(hitMap.get('sender_name')=='OMS'){
                    dataconstract.put('type','Refund Voucher');
                }
                else{
                    dataconstract.put('type','Goodwill Voucher');
                }
                
                responsevaluelist.add( new responsevalue(dataconstract));
            }
        }
        return responsevaluelist;
    }

    //innser class for wrapping the response into MAP
    public class Responsevalue{
        @AuraEnabled public string type{get;set;}
        @AuraEnabled public string code{get;set;}
        @AuraEnabled public String issueDate{get;set;}
        @AuraEnabled public String expiryDate{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public Decimal balanceValue{get;set;}
        @AuraEnabled public Boolean enabled;
        @AuraEnabled public String merchantId {get;set;}
        @AuraEnabled public String redeemed;
        @AuraEnabled public String sender_name;

        public Responsevalue(Map<String,Object> dataconstract){
            this.type = String.valueOf(dataconstract.get('type'));
            this.code = String.valueOf(dataconstract.get('code'));
            this.issueDate = String.valueOf(dataconstract.get('issueDate'));
            this.expiryDate = String.valueOf(dataconstract.get('expiryDate')) ;
            this.status = String.valueOf(dataconstract.get('status')) ;
            this.balanceValue = Decimal.valueOf(String.valueOf(dataconstract.get('balanceValue'))); 
            this.enabled = Boolean.valueOf(dataconstract.get('enabled')) ;
            this.merchantId = String.valueOf(dataconstract.get('merchantId'));
            this.redeemed = String.valueOf(dataconstract.get('redeemed'));
            this.sender_name = String.valueOf(dataconstract.get('sender_name'));
        }
    }
}