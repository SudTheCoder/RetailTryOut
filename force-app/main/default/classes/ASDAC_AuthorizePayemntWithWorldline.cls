/************************************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-05-22
* @description                  : Paymnet Aithorization with tken inout for the customer
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                22-May-2023      Created the class
* Niteesh Kumar				   05-July-2023 	Class Modified to add extra header
***************************************************************************************************/
public with sharing class ASDAC_AuthorizePayemntWithWorldline {
    static final string CURRENTTIME =Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
    
    /** ****************************************************************************************************
* @description Method used to create string to Hash and do callout for Payment authorization
* @return  Json body as string format
* @parameter CustomerCRMId and token for the customer
* ****************************************************************************************************
*/
    public static String getWorldlineAPIAuthorization(Asset asst,Integer amount){
      ASDAC_LoyaltyPaymentAuth__mdt paymentAuth = ASDAC_LoyaltyPaymentAuth__mdt.getInstance('worldline_Payment_Auth');
        Http httpCall = new Http();
        HttpRequest httpRequest = new HttpRequest();
        String apiKey = paymentAuth.apiKey__c;
        String apiSecret =paymentAuth.apiSecret__c;
        String pspId = paymentAuth.pspId__c;
        String stringToHash;
        String requestMethod = 'POST';
        String contentType = 'application/json';
        String uriResource = '/payments';
        String endpointURL = '/v2/' + pspId + uriResource;
        String encodedSignature = '';
        String authorizationValue = '';
       
        stringToHash = requestMethod + '\n' + contentType + '\n' + CURRENTTIME + '\n' + endpointURL + '\n';
        
        try{
            Blob hmacSHA256blob = Crypto.generateMac('HmacSHA256',Blob.valueOf(stringToHash),Blob.valueOf(apiSecret));
            encodedSignature = EncodingUtil.base64Encode(hmacSHA256blob);
            authorizationValue = 'GCS v1HMAC:' + apiKey + ':' + encodedSignature;
            String jsonString = createJsonPayload(asst, amount);
            httpRequest.setEndpoint(paymentAuth.worldlineEndPoint__c);
            httpRequest.setMethod(requestMethod);
            httpRequest.setHeader('Authorization',authorizationValue);
            httpRequest.setHeader('Date',CURRENTTIME);
            httpRequest.setHeader('Content-Type',contentType);
            httpRequest.setHeader('Accept', '*/*');
            httpRequest.setBody(jsonString);
            HttpResponse httpResponse = httpCall.send(httpRequest);
            return httpResponse.getBody();
        }catch (Exception ex){
            System.debug(' Authorization Error : '+ex.getMessage());
            return null;
        }
    }
        
        /** ****************************************************************************************************
        * @description Method used to create request payload to do callout for Payment authorization.
        * @return  Json body as string format
        * @parameter CustomerCRMId and token for the customer
        * ****************************************************************************************************
        */
        Public static string createJsonPayload(Asset asst , Integer amount){
            ASDAC_PaymentPayloadWrapper.ThreeDSecure secure = new ASDAC_PaymentPayloadWrapper.ThreeDSecure();
            ASDAC_PaymentPayloadWrapper.Recurring rec = new ASDAC_PaymentPayloadWrapper.Recurring();
            rec.recurringPaymentSequenceIndicator = 'recurring';
            secure.skipAuthentication = true;
            ASDAC_PaymentPayloadWrapper.CardPaymentMethodSpecificInput cpmsi = new ASDAC_PaymentPayloadWrapper.CardPaymentMethodSpecificInput();
            cpmsi.token= asst.Customer_Card__r.CardToken__c;
            cpmsi.authorizationMode = 'PRE_AUTHORIZATION';
            cpmsi.transactionChannel = 'ECOMMERCE';
            cpmsi.threeDSecure = secure;
            cpmsi.paymentProductId = Integer.valueOf(asst.Customer_Card__r.CardBrand__c);
            cpmsi.schemeReferenceData =String.valueOf(asst.SchemeReferenceData__c);
            cpmsi.recurring = rec;
            cpmsi.isRecurring = true;
            ASDAC_PaymentPayloadWrapper.References ref = new ASDAC_PaymentPayloadWrapper.References();
            ref.merchantReference = '500000'+asst.LoyaltyOrderNo__c+(Datetime.now()).getTime();
            ASDAC_PaymentPayloadWrapper.AmountOfMoney aom = new ASDAC_PaymentPayloadWrapper.AmountOfMoney();
            aom.currencyCode=ASDAC_GlobalConstants.CURRENCYCODE;
            aom.amount = amount;
            ASDAC_PaymentPayloadWrapper.Order order = new ASDAC_PaymentPayloadWrapper.Order();
            order.amountOfMoney = aom;
            order.references = ref;
            ASDAC_PaymentPayloadWrapper body = new ASDAC_PaymentPayloadWrapper();
            body.order = order;
            body.cardPaymentMethodSpecificInput = cpmsi;
            String jsonString = JSON.serialize(body);
            System.debug(jsonString);
            return jsonString;
        }
    }