public with sharing class ASDAC_OrderRequest {
    @AuraEnabled
    public String orgId;
    public String createUser;
    public String updateUser;
    @AuraEnabled
    public String sellingChannel;
    public String orderId; // Not required in future, To be generated as of now: RETURN_{{salesOrderId}}_{{uniqueRandomId}}
    public String orderType;
    public String orderCategory;
    @AuraEnabled
    public Datetime orderDate = Datetime.now();
    @AuraEnabled
    public String customerId;
    public Boolean partialFillAllowed = true;
    // added for return request
    public String cartId;
    public String billingCurrency;
    @AuraEnabled
    public ASDAC_OrderTotal orderTotals;
    @AuraEnabled
    public List<ASDAC_OrderAssociationRequest> associationDetails; // Exchange Order Id: Not required in future, To be generated as of now: EXCHANGE_{{salesOrderId}}_{{uniqueRandomId}}
    @AuraEnabled
    public List<ASDAC_OrderLineRequest> orderLines = new List<ASDAC_OrderLineRequest>();
    public List<ASDAC_OrderDiscountRequest> discounts;
    public List<ASDAC_OrderCommentRequest> comments;
    public List<ASDAC_OrderCharges> charges;
    public String reasonCode;
    @AuraEnabled
  	public CustomFields customFields;
    public List<ASDAC_OrderAddressInfo> addressInfo;
    
    public class CustomFields {
    @AuraEnabled
    public String returnReason;
    @AuraEnabled
    public String returnNotes;
    @AuraEnabled
    public String eVouchersAsDiscount;
    public ASDAC_OrderRefundFraudWrapper fraud;
  }

}