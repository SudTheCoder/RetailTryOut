public with sharing class ASDAC_OrderPaymentMethodResponse {
    @AuraEnabled
    public String paymentMethodId;
    @AuraEnabled
    public String paymentType;
    @AuraEnabled
    public String paypalId;
    @AuraEnabled
    public String cardType;
    @AuraEnabled
    public String cardNumber;
    @AuraEnabled
    public String cardExpiry{
        get{
            return expirationMonth +'/'+expirationYear;
        }
    }
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String address;
    @AuraEnabled
    public String phone;
    @AuraEnabled
    public String piHash;
    @AuraEnabled
    public String cardHolder;
    @AuraEnabled
    public String transactionType;
    @AuraEnabled 
    public String authorizationId;    
    @AuraEnabled
    public String arnNumber;
    @AuraEnabled 
    public Decimal amount;
    @AuraEnabled 
    public String transactionDateTime;
    @AuraEnabled 
    public String approvalCode;
    @AuraEnabled 
    public Decimal totalInvoiced;
    @AuraEnabled
    public String tokenizedCard;
    @AuraEnabled
    public String giftCardNumber;
    @AuraEnabled
    public String expirationMonth;
    @AuraEnabled
    public String expirationYear;
    @AuraEnabled
    public String cardStatus;
    @AuraEnabled
    public Boolean isCardDisabled{
        get{
            return ASDAC_OMSConstants.DISABLED_STRING.equalsIgnoreCase(cardStatus);
        }
    }
    @AuraEnabled
    public ASDAC_OrderContact billToContact = new ASDAC_OrderContact();
    @AuraEnabled
    public ASDAC_OrderAddress billToAddress = new ASDAC_OrderAddress();
    @AuraEnabled
    public List<TransactionsDetailsWrapper> transactionsDetails;

    public class TransactionsDetailsWrapper{
        @AuraEnabled 
        public String processType;
        @AuraEnabled 
        public Decimal amount;
        @AuraEnabled 
        public String transactionId;
        public String updatedTime;
        @AuraEnabled 
        public String transactionDateTime{
            get{
                return ASDAC_OrderUtility.convertStringToDateTimeString(updatedTime);
            }
        }
        @AuraEnabled
        public String approvalCode;
        @AuraEnabled
        public String status;
        @AuraEnabled
        public String arnNumber;
        @AuraEnabled
        public Boolean isSuccess {
            get {
                return ASDAC_OMSConstants.SUCCESS_STRING.equalsIgnoreCase(approvalCode);
            }
        }
        @AuraEnabled
        public Boolean isGhsPending {
            get {
                return ASDAC_OMSConstants.PENDING_STRING.equalsIgnoreCase(status);
            }
        }
        @AuraEnabled
        public Boolean isGhsSuccess {
            get {
                return ASDAC_OMSConstants.SUCCESS_STRING.equalsIgnoreCase(status);
            }
        }
        @AuraEnabled
        public Boolean isGhsError{
            get {
                return ASDAC_OMSConstants.ERROR_STRING.equalsIgnoreCase(status);
            }
        }
    }

    @AuraEnabled
    public Boolean isPaypal {
        get {
            return paymentType?.toUpperCase() == ASDAC_OMSConstants.PAYPAL_STRING;
        }
    }
    
    @AuraEnabled
    public Boolean isCreditCard {
        get {
            return paymentType?.toUpperCase() == ASDAC_OMSConstants.CREDIT_CARD_STRING;
        }
    }
    
    @AuraEnabled
    public Boolean isVoucher {
        get {
            return paymentType?.toUpperCase() == ASDAC_OMSConstants.VOUCHER_STRING;
        }
    }
    
    @AuraEnabled
    public Boolean isGiftCard {
        get {
            return paymentType?.toUpperCase() == ASDAC_OMSConstants.GIFT_CARD_STRING;
        }
    }
    
    @AuraEnabled
    public Boolean isSuccess {
        get {
            return ASDAC_OMSConstants.SUCCESS_STRING.equalsIgnoreCase(approvalCode);
        }
    }
}