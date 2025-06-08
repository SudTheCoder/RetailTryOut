/***********************************************************************************************************************
* author                       : Niteesh Kumar
* date                         : 2023-03-02
* Component Type               : Apex Class
* component Name               : ASDAC_PaymentResponseWrapper
* description                  : ASDAC-7358, ASDAC-8203 - GHS - DP SME - Monthly instalment payload along with Payment authorization
* modified by				   : Niteesh Kumar
************************************************************************************************************************/
public with sharing class ASDAC_PaymentResponseWrapper {
    public static Map<String,string> worldlineAuthenticationRequest(Asset objAsset, String strReqName){
        Decimal amountToAuthenticate = 0.0;
        Map<String,String> paymentAuthResponse = new Map<String,String>();
        try{
            if(strReqName=='AutoRenew'){
                amountToAuthenticate = [Select id,ProductCode,PlanPrice__c,NumberOfInstallments__c,ItemId__c,Name from Product2 where id=:objAsset.Product2Id].PlanPrice__c;
            }else if(strReqName=='Monthly' && !Test.isRunningTest()){
                amountToAuthenticate = [Select Id,BillingPeriodAmount from BillingSchedule where ReferenceEntityId = :objAsset.loyaltyOrderNumber__c].BillingPeriodAmount;
            }
            Integer amount= Integer.ValueOf(amountToAuthenticate*100);
            String strWordlineAuth = ASDAC_AuthorizePayemntWithWorldline.getWorldlineAPIAuthorization(objAsset,amount);
            Map<String,Object> objPaymentResponse =(Map<String,Object>)JSON.deserializeUntyped(strWordlineAuth);
            if((Map<String,Object>)objPaymentResponse.get('payment') != null){
                Map<String,Object> payment = (Map<String,Object>)objPaymentResponse.get('payment');
                    if(String.valueOf(payment.get('status'))=='PENDING_CAPTURE'){
                        Map<String,Object> paymentOutput = (Map<String,Object>)payment.get('paymentOutput');
                  		Map<String,Object> references = (Map<String,Object>)paymentOutput.get('references');
                        paymentAuthResponse.put('paymentId',String.valueOf(payment.get('id')));
                        paymentAuthResponse.put('merchantReference',String.valueOf(references.get('merchantReference')));
                        paymentAuthResponse.put('isAuthorized','True');
                    }
            }else if(objPaymentResponse.get('errorId') != null){
                throw new ASDAC_ErrorHandler.CustomPaymentException('Worldline authentication failed');
            }
        }catch(exception ex){
            ASDAC_Logger.logException(ex, ASDAC_GlobalConstants.STRING_LOYALTY, 'Exception occured during worldline authentication failure', 'ASDAC_PaymentResponseWrapper');
            ASDAC_Logger.writeLogsToDatabase();
        }
        return paymentAuthResponse;
    } 
}