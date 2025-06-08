/**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 12/05/2023
* @description                  : ASDAC_7971 Rel C - GHS - GV - Integrate CCA UI with API for issuing single goodwill vouchers (with / without wallet)

**********************************************************************************/

public with sharing class ASDAC_GoodWillWalletIdentity {
    
    @AuraEnabled(Cacheable=true)
    public static String doWalletIdentity(String accId, String strVoucherType, Goodwill__c gw){
        try{
            if(gw.BusinessArea__c == 'George'){
                return JSON.serialize(ASDAC_GetVoucherCode.getGeorgeVoucherCode(gw));
            }else{
                return JSON.serialize(ASDAC_GoodWillWalletIdentity.callEagleEyeForVoucher(accId,(Integer)(gw.VoucherAmount__c*100),strVoucherType,gw.ReasonCode__c)); 
            }
        }catch(Exception e){
            writeLogsToDatabase(e.getMessage());
            system.debug('Error: '+e.getMessage());
            throw new AuraException(e.getMessage());  
        }
    }
    @future(callout =true)
    public static void callGHSVoucher(String accId, Integer discountAmount , String strVoucherType,String strReasonCode){
        ASDAC_GoodWillWalletIdentity.callEagleEyeForVoucher(accId,discountAmount ,strVoucherType,strReasonCode); 
    }
    
    Public static ASDAC_GoodWillWalletIdentity.ResponseWrapper callEagleEyeForVoucher(String accId, Integer discountAmount , String strVoucherType, String strReasonCode){
        try {
            
            String crmId = [select personContactid from Account where id=: accId limit 1].personContactid;
            HttpRequest httpRequest = ASDAC_HashTokenGenerator.sendAISRequest('', 'GET', '/wallet?identity-value=' + crmId);
            
            Http http = new Http();
            
            HttpResponse response = http.send(httpRequest);
            if (response.getStatusCode() == 200) {
                ASDAC_GoodWillWalletIdentity.ResponseWrapper respWrap = (ASDAC_GoodWillWalletIdentity.ResponseWrapper)JSON.deserialize(response.getBody(), ASDAC_GoodWillWalletIdentity.ResponseWrapper.class);
                String walletId = respWrap.walletId;
                
                if (walletId != null) {
                    return ASDAC_AddCouponToWallet.addCoupon(discountAmount, walletId, strVoucherType, accId,strReasonCode);
                } else {
                    return null;         
                }
            } else if(response.getStatusCode() == 404){
                return ASDAC_GoodWillWalletCreation.createWallet(crmId, discountAmount,accId,strReasonCode,strVoucherType);  
            } else {
                // Handle the case when the response status code is not 200
                Map<String,Object> result = (Map<String,Object>)json.deserializeUntyped(response.getBody());
                if(result.get('errorMessage')!=null){
                    throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage+' : '+result.get('errorMessage'));
                }else{
                    throw new AuraException(System.Label.ASDAC_IssueEVoucherTechnicalExceptionMessage);
                }
            }
        } catch (Exception e) {
            // Handle any exceptions that might occur during the execution of the try block
            writeLogsToDatabase(e.getMessage());
            system.debug('Error Msg : '+e.getMessage());
            throw new AuraException(e.getMessage());
        }    
    }
    
    
    /**********************************************************************************

* @author                       : Abhay Patle
* @date                         : 25/05/2023
* @description                  : ASDAC_7904 Rel C - GHS - GV - CCA UI API integration - View Customer's Voucher History


**AuraEnabled method called from AsdacGoodwillVoucherDetails LWC component for displaying GoodWill vouchers on CCS
**Modified by Abhay Patle on 25-5-2022

**********************************************************************************/
    
    @AuraEnabled (Cacheable=true)
    Public static String getWalletForGettingVouchers(String accId){
        try{
            
            String crmId = [select personContactid from Account where id=: accId limit 1].personContactid;
            
            HttpRequest httpRequest = ASDAC_HashTokenGenerator.sendAISRequest('', 'GET', '/wallet?identity-value=' + crmId);
            Http http = new Http();
            
            HttpResponse response = http.send(httpRequest);
            ASDAC_GoodWillWalletIdentity.ResponseWrapper respWrap = (ASDAC_GoodWillWalletIdentity.ResponseWrapper)JSON.deserialize(response.getBody(), ASDAC_GoodWillWalletIdentity.ResponseWrapper.class);
            
            String walletId = respWrap.walletId;
            
            return walletId;
            
        }
        
        Catch(Exception e){
            ASDAC_Logger.logException(e, ASDAC_GlobalConstants.STRING_LOYALTY, 'Voucher issue Error', 'ASDAC_GoodWillWalletIdentity');
            System.debug('Error Message: '+e.getMessage());
            system.debug('Line '+e.getLineNumber());
            return null;
        }
    }
    
    @Future
    private static void writeLogsToDatabase(String exceptionMessage) {
        ASDAC_Logger.logException(exceptionMessage, ASDAC_GlobalConstants.STRING_LOYALTY, 'ASDAC_GoodWillWalletIdentity');
        ASDAC_Logger.writeLogsToDatabase();
    }
    
    public class ResponseWrapper {
        public String gift_certificate_code;
        public String expiry_date;
        public String accountId;
        public String walletId;
        public AccountsWrapper accounts;
    }
    
    public class AccountsWrapper{
        public CampaignWrapper campaign;
    }
    
    public class CampaignWrapper{
        public List<AccountDetailsWrapper> results;
    }
    
    public class AccountDetailsWrapper{
        public String accountId;
        public String walletId;
    }
    
}