public with sharing class ASDAC_ManualRefundRequestController {
    private static String WORLDLINE_PAYOUT_GEORGE_METADATA;
    private static String WORLDLINE_PAYOUT_GHS_METADATA;
    @AuraEnabled(cacheable=false)
    public static String doManualRefundCallout(String stringifiedJSON){
        
		return doManualRefundCalloutPrv(stringifiedJSON);
	}
		 private static String doManualRefundCalloutPrv(String stringifiedJSON){
		
		String integrationMetadata = WORLDLINE_PAYOUT_GEORGE_METADATA;     
        ASDAC_IntegrationUtility.ResultWrapper resultWrap;
        try {           
            DetailsWrapper requestDetails = (DetailsWrapper) JSON.deserialize(stringifiedJSON, DetailsWrapper.class);
		
		String methodType =requestDetails.methodType;
	     if (methodType=='Get')
		 {
			 WORLDLINE_PAYOUT_GEORGE_METADATA ='WorldlineGetPayout';
			 WORLDLINE_PAYOUT_GHS_METADATA ='WorldlineGetPayoutGHS';
			 
		 }
		
		 else 
		 {
			  WORLDLINE_PAYOUT_GEORGE_METADATA ='WorldlinePayout';
			 WORLDLINE_PAYOUT_GHS_METADATA ='WorldlinePayoutGHS';
			 
		 }
            integrationMetadata = requestDetails.businessArea == 'George' ? WORLDLINE_PAYOUT_GEORGE_METADATA : WORLDLINE_PAYOUT_GHS_METADATA;      
            resultWrap = ASDAC_CalloutService.getResponseMethod(integrationMetadata, stringifiedJSON);
            if (ASDAC_ErrorHandler.checkForException(integrationMetadata,resultWrap.statusCode)) {
                throw new ASDAC_ErrorHandler.CustomCalloutException(resultWrap);
            }
            else if (ASDAC_ErrorHandler.checkForEmptyResponse(resultWrap.statusCode)) {
                return null;
            }
        }catch (ASDAC_ErrorHandler.CustomCalloutException ex) {
            resultWrap.strMessage = ASDAC_ErrorHandler.getErrorMessage(integrationMetadata, ex.statusCode);
            String logMessage = '';
            logMessage += 'Exception Message:\n'+ ex.getMessage() + '\n\n';
            logMessage += 'Request:\n'+ stringifiedJSON + '\n\n';
            logMessage += 'Response:\n'+ resultWrap.strData;
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, logMessage);
            ASDAC_Logger.writeLogsToDatabase();            
        }catch (Exception ex) {
            String logMessage = '';
            logMessage += 'Exception Message:\n'+ ex.getMessage() + '\n\n';
            logMessage += 'Request:\n'+ stringifiedJSON + '\n\n';
            logMessage += 'Response:\n'+ resultWrap.strData;
            logException(ex, ASDAC_GlobalConstants.STRING_CONTACT_CENTRE, logMessage);
            throw ex;
        } 
        return JSON.serialize(resultWrap);
    }
    @AuraEnabled(cacheable=true)
    public static String getCustomerDefaultCard(Id recordId) {
        String cardToken = '';
        try {
            List<CustomerCard__c> customerCard = [SELECT CardToken__c FROM CustomerCard__c WHERE AccountId__c =: recordId and DefaultCard__c = true WITH SECURITY_ENFORCED Limit 1];  
            if (customerCard.size() > 0) {
                cardToken = customerCard[0].CardToken__c;
            }
            else{
                cardToken = null;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return cardToken;    
    }
    
    private static void logException(Exception ex, String source, String message) {
        ASDAC_Logger.logException(ex, source, message, 'ASDAC_ManualRefundController');
    }

    @AuraEnabled(cacheable=true)
    public static Decimal getManualRefundLimit() {
        try {
            Id userId = UserInfo.getUserId();
            User usr = [SELECT Id, UserRole.Name FROM User WHERE Id=:userId];
            if(String.isNotBlank(usr.UserRole.Name)){
                ASDAC_ManualRefundRoleLimit__mdt manualRefundMetaData = [SELECT Id, JobRole__c, ManualRefundLimit__c FROM ASDAC_ManualRefundRoleLimit__mdt where JobRole__c = :usr.UserRole.Name LIMIT 1];
                return manualRefundMetaData.ManualRefundLimit__c;
            }
            return null;
            
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
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
}