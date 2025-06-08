/**
 * @description       : service class for worldline Payout
 * @author            : Arjun Singh
 * @group             : 
 * @last modified on  : 04-10-2024
 * @last modified by  : Arjun Singh
**/
public with sharing class ASDAC_WorldlinePayoutService implements ASDAC_IntegrationServices {

    private final static String WORLDLINE_PAYOUT_GEORGE_METADATA = 'Worldline_Payout_George';
    private final static String WORLDLINE_PAYOUT_GHS_METADATA = 'Worldline_Payout_GHS';
	
    /**
    * @description 
    * @author Arjun Singh | 30-06-2023 
    * @param stringifiedJSON 
    * @return String 
    **/
    public String createRequest(String stringifiedJSON) {
		DetailsWrapper requestDetails = (DetailsWrapper) JSON.deserialize(stringifiedJSON, DetailsWrapper.class);
		String payoutId =requestDetails.payoutId;
		String methodType =requestDetails.methodType;
	     if (methodType=='Get')
		 {
			 return null;
			 
		 }
		 else {
		 
		try {
         
            // Deserialize the JSON string into the wrapper class
            WorldlinePyaoutRequestWrapper requestWrapper = new WorldlinePyaoutRequestWrapper();
            requestWrapper.amountOfMoney = new AmountOfMoney() ;
            requestWrapper.amountOfMoney.amount = (Integer)(requestDetails.payoutAmount.setScale(2) * 100); 
            requestWrapper.amountOfMoney.currencyCode = 'GBP';
            requestWrapper.cardPayoutMethodSpecificInput = new CardPayoutMethodSpecificInput();
            requestWrapper.cardPayoutMethodSpecificInput.token =  requestDetails.cardToken;
            requestWrapper.references = new References();
            String  merchantReference =  String.valueOf(System.currentTimeMillis());
            // Truncate to 40 characters if necessary
            if (merchantReference.length() > 40) {
                merchantReference = merchantReference.substring(0, 40);
            }
            requestWrapper.references.merchantReference =  merchantReference;// timestamp
                
            // Serialize the wrapper object back to a JSON string (for returning or further use)
            String serializedRequest = JSON.serialize(requestWrapper);
            
            return serializedRequest;  // Return the serialized JSON string
        } catch (Exception ex) {
            System.debug('Error in deserializing JSON: ' + ex.getMessage());
            return null;
        }
	}
    }

    public Map<String, String> createRequestHeader(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {
        Map<String, String> reqHeader = new Map<String, String>(); 
        String requestMethod;
        String endpointURL;
	String contentType;
        try{
          
DetailsWrapper requestDetails = (DetailsWrapper) JSON.deserialize(stringifiedJSON, DetailsWrapper.class);
		String payoutId =requestDetails.payoutId;
		String methodType =requestDetails.methodType;
	    
          ASDAC_LoyaltyPaymentAuth__mdt paymentAuth = requestDetails.businessArea == 'George' ? ASDAC_LoyaltyPaymentAuth__mdt.getInstance(WORLDLINE_PAYOUT_GEORGE_METADATA) : ASDAC_LoyaltyPaymentAuth__mdt.getInstance(WORLDLINE_PAYOUT_GHS_METADATA);
            String key = paymentAuth.apiKey__c;
            String secret =paymentAuth.apiSecret__c;
            String pspId = paymentAuth.pspId__c;
            String currTime = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss') + ' GMT';
			if (methodType=='Get')
			{
				requestMethod = 'GET';
				endpointURL = '/v2/' + pspId + '/payouts/' + payoutId;
				contentType = '';
			}
			Else{
             requestMethod = 'POST';
			 endpointURL = '/v2/'+pspId+'/payouts';
			 contentType = 'application/json';
			}
            
            
            String encodedSignature = '';
            String authorizationValue = '';
            String stringToHash = requestMethod + '\n' + contentType + '\n' + currTime + '\n' + endpointURL + '\n';
            
            Blob hmacSHA256blob = Crypto.generateMac('HmacSHA256',Blob.valueOf(stringToHash),Blob.valueOf(secret));
            encodedSignature = EncodingUtil.base64Encode(hmacSHA256blob);
            authorizationValue = 'GCS v1HMAC:' + key + ':' + encodedSignature;
            reqHeader.put('Authorization', authorizationValue);
            reqHeader.put('Date', currTime);
        } catch(Exception ex){
            System.debug('Exception :'+ex.getMessage());
        }
        return reqHeader;
    }

	/**
     * Purpose    : Method to perform callout
     * Parameters : ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON
     * Returns    : ASDAC_IntegrationUtility.ResultWrapper
     **/    
    public ASDAC_IntegrationUtility.ResultWrapper doCallout(ASDAC_IntegrationMetadata__mdt integrationMdt, String stringifiedJSON) {        
              DetailsWrapper requestDetails = (DetailsWrapper) JSON.deserialize(stringifiedJSON, DetailsWrapper.class);
        ASDAC_IntegrationUtility.IntegrationWrapper initWrapper = new ASDAC_IntegrationUtility.IntegrationWrapper();
		String payoutId =requestDetails.payoutId;
        initWrapper.metadataRecord = integrationMdt;
        initWrapper.requestBody = createRequest(stringifiedJSON);
        initWrapper.requestHeaders = createRequestHeader(integrationMdt,stringifiedJSON);
		initWrapper.listOfQueryParameters = new List<String>{payoutId};
        HttpResponse resp = ASDAC_IntegrationUtility.sendRequest(initWrapper, false).response;
        return new ASDAC_IntegrationUtility.ResultWrapper(resp);
    }    

    public Class DetailsWrapper {
        public String recordId;
        public String businessArea;
        public Decimal payoutAmount;
        public String reasonCode;
        public String notes;
        public String cardToken;
	public String  payoutID;
	public String  methodType;
		
    }

    public class WorldlinePyaoutRequestWrapper{
        public AmountOfMoney amountOfMoney;
        public CardPayoutMethodSpecificInput cardPayoutMethodSpecificInput;
        public References references;
    }

    // These classes are now outside the wrapper class to avoid nesting
    public class AmountOfMoney {
        public Integer amount;	//1000
        public String currencyCode;	//GBP
    }

    public class CardPayoutMethodSpecificInput {
        public String token;
    }

    public class References {
        public String merchantReference;
    }
    
}