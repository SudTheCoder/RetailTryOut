public with sharing class ASDAC_DeliveryPassRefundCallout {
    
    //Constants
    public static final Boolean blnFalse = false;
    public static final Boolean blnTrue = true;
    public static final String strNull = null;
    public static final Integer intTwoHundred = 200;
    public static final Integer intTwoHundredOne = 201;
    
    @future(callout=true)
    public static void initiateRefund(Id id) {
        try{
            Asset objAssetOrder = [SELECT Id, Customer_Card__c,Auto_Renew__c,Subscription_Purchase_Price__c,Refund_Amount__c, ContactId,Refund_Status__c,Refund_Order_Id__c, Product2Id,Product2.ItemId__c, Product2.Description,Account.PersonContactId,shopOrderNumber__c,PurchaseDate, UsageEndDate, loyaltyOrderNumber__c, Renewal_Payment_Status__c FROM Asset where id=:Id];
             CustomerCard__c objcard = [SELECT Id,ExternalId__c,AddressId__r.AddressLine1__c, AddressId__r.AddressLine2__c,AddressId__r.City__c,AddressId__r.PostalCode__c,AddressId__r.Country__c,NameOnCard__c  from CustomerCard__c where id= :objAssetOrder.Customer_Card__c];
            Contact objContact = [Select id,FirstName,LastName,MiddleName,Phone,Email from Contact where id =: objAssetOrder.ContactId];
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('updateUser', 'LOYALTY');
            gen.writeStringField('orgId', 'ASDA');
            gen.writeStringField('sellingChannel', 'ASDA_GROCERIES');
            gen.writeStringField('orderType', 'ReturnOrder');
            DateTime now = System.now();
            String formattedDateTime = now.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            gen.writeStringField('orderDate', formattedDateTime);
            gen.writeStringField('orderCategory', 'ReturnOrder');
            gen.writeStringField('customerId', objAssetOrder.ContactId);
            gen.writeBooleanField('partialFillAllowed', true);
            gen.writeStringField('billingCurrency', 'GBP');
            
            gen.writeFieldName('associationDetails');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('orgId', 'ASDA');
            gen.writeStringField('associationType', 'SalesOrder');
            gen.writeStringField('sellingChannel', 'ASDA_GROCERIES');
            gen.writeStringField('orderId', objAssetOrder.shopOrderNumber__c);
            gen.writeEndObject();
            gen.writeEndArray();
            
            // addressInfo
            gen.writeFieldName('addressInfo');
            gen.writeStartArray();
            addCustomerInfo(gen,objContact,objcard,0);
            addCustomerInfo(gen,objContact,objcard,1);
            gen.writeEndArray();
            
            
            gen.writeFieldName('orderLines');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeNumberField('orderLineId', 1);
            gen.writeStringField('updateUser', 'LOYALTY');
            gen.writeStringField('orderLineType', 'ASDADelivery');
			gen.writeStringField('productType', 'DELIVERY_PASS');
            gen.writeStringField('fulfillmentType', 'DIGITAL');
            gen.writeStringField('fulfillmentService', 'STANDARD');
            gen.writeNumberField('quantity', 1);
            gen.writeStringField('productId', objAssetOrder.Product2.ItemId__c);
            gen.writeStringField('productDescription', objAssetOrder.Product2.Description);
            gen.writeStringField('uom', 'EACH');
            
            gen.writeFieldName('associationDetails');
            gen.writeStartArray();
            gen.writeStartObject();
            gen.writeStringField('associationType', 'SalesOrder');
            gen.writeNumberField('associatedLineId', 1);
            gen.writeEndObject();
            gen.writeEndArray();
            
            gen.writeFieldName('customFields');
            gen.writeStartObject();
            gen.writeFieldName('fraud');
            gen.writeStartObject();
            gen.writeBooleanField('fraudBypass', true);
            gen.writeEndObject();
            gen.writeStringField('returnType', 'Original');
            gen.writeStringField('returnReason', System.Label.ASDAC_DP_Refund_Return_Reason);
            gen.writeStringField('returnNotes', System.Label.ASDAC_DP_Refund_Return_Notes);
            gen.writeEndObject();
            
            gen.writeStringField('reasonCode', System.Label.ASDAC_DP_Refund_Return_Reason);
            gen.writeEndObject();
            gen.writeEndArray();
            
            gen.writeFieldName('customFields');
            gen.writeStartObject();
            gen.writeFieldName('fraud');
            gen.writeStartObject();
            gen.writeBooleanField('fraudBypass', true);
            gen.writeEndObject();
            gen.writeStringField('returnType', 'Original');
            gen.writeStringField('returnReason', System.Label.ASDAC_DP_Refund_Return_Reason);
            gen.writeStringField('returnNotes', System.Label.ASDAC_DP_Refund_Return_Notes);
            gen.writeEndObject();
            
            gen.writeEndObject();
            
            String jsonStr = gen.getAsString();
            system.debug('jsonStr '+jsonStr);
            HttpRequest objReq = new HttpRequest();
            ASDAC_Loyalty_base_urls__mdt urlRecurring = ASDAC_Loyalty_base_urls__mdt.getInstance('OrderLineRefund');
            String strEndpoint = urlRecurring.Traget_endpoint__c;
            objReq.setEndpoint(strEndpoint);
            objReq.setMethod('POST');
            objReq.setHeader('Source', 'sfsc');
            objReq.setHeader('Content-Type', 'application/json');
            objReq.setBody(jsonStr);
            
            Http http = new Http();
            HttpResponse httpResponse =http.send(objReq);
            String strResponse = httpResponse.getBody();
            
            if (httpResponse.getStatusCode() == intTwoHundred || httpResponse.getStatusCode() == intTwoHundredOne) {  
                
                Map<String, Object> jsonObj = (Map<String, Object>)JSON.deserializeUntyped(strResponse);

                String orderId = (String)jsonObj.get('orderId');
                Map<String, Object> aggregatedState = (Map<String, Object>)jsonObj.get('aggregatedState');
                List<Object> details = (List<Object>)aggregatedState.get('details');
                String state = '';
                if (details != null && !details.isEmpty()) {
                    Map<String, Object> firstDetail = (Map<String, Object>)details[0];
                    state = (String)firstDetail.get('state');
                }
				objAssetOrder.Refund_Status__c = state;
                objAssetOrder.Refund_Order_Id__c = orderId;
                objAssetOrder.Refund_Amount__c = objAssetOrder.Subscription_Purchase_Price__c;
                
                update objAssetOrder;
            } else {  
                
                throw new CalloutException( httpResponse.getBody() );  
            }
            
        }catch(Exception ex){
            System.debug(ex.getMessage());
            System.debug(ex.getstacktracestring());
        }
    }
    
    public static void addCustomerInfo(JSONGenerator gen,Contact objContact,CustomerCard__c objcard,integer i){
                gen.writeStartObject();
                gen.writeFieldName('contact');
                gen.writeStartObject();
                String strFname = String.isNotEmpty(objContact.FirstName) ? objContact.FirstName : '';
                gen.writeStringField('firstName', strFname);
                String strLname = String.isNotEmpty(objContact.LastName) ? objContact.LastName : '';
                gen.writeStringField('lastName', strLname);
                String strMname = String.isNotEmpty(objContact.MiddleName) ? objContact.MiddleName : '';
                gen.writeStringField('middleName', strMname);
                String strPhone = String.isNotEmpty(objContact.Phone) ? objContact.Phone : '';
                gen.writeStringField('phone', strPhone);
                String strEmail = String.isNotEmpty(objContact.Email) ? objContact.Email : '';
                gen.writeStringField('email', strEmail);
                gen.writeEndObject();
                gen.writeFieldName('address');
                gen.writeStartObject();
                String strAddress1 = String.isNotEmpty(objcard.AddressId__r.AddressLine1__c) ? objcard.AddressId__r.AddressLine1__c : '';
                gen.writeStringField('addressLine1', strAddress1);
                String strAddress2 = String.isNotEmpty(objcard.AddressId__r.AddressLine2__c) ? objcard.AddressId__r.AddressLine2__c : '';
                gen.writeStringField('addressLine2', strAddress2);
                String strCity = String.isNotEmpty(objcard.AddressId__r.City__c) ? objcard.AddressId__r.City__c : '';
                gen.writeStringField('city', strCity);
                gen.writeStringField('state', '');
                String strCountryCode = String.isNotEmpty(objcard.AddressId__r.Country__c) ? objcard.AddressId__r.Country__c : '';
                gen.writeStringField('country', strCountryCode);
                String strPostalCode = String.isNotEmpty(objcard.AddressId__r.PostalCode__c) ? objcard.AddressId__r.PostalCode__c : '';
                gen.writeStringField('zipCode', strPostalCode);
                gen.writeEndObject();
                gen.writeBooleanField('isActive', true);
                gen.writeStringField('type', (i == 0) ? 'billTo' : 'shipTo');
                gen.writeEndObject();
    }
}