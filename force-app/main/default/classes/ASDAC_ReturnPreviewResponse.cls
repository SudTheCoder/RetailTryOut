public with sharing class ASDAC_ReturnPreviewResponse {
    @AuraEnabled public String updateTime;
    @AuraEnabled public String orgId;
	@AuraEnabled public String orderId;
    @AuraEnabled public String sellingChannel = ASDAC_OMSConstants.GEORGECOM_STRING;
    @AuraEnabled public String customerId;
    @AuraEnabled public String orderCategory;
    @AuraEnabled public String orderDate;
    @AuraEnabled public String billingCurrency;
    @AuraEnabled public String refundStatus;
    @AuraEnabled public String refundPaymentMethod;
    @AuraEnabled public ASDAC_OrderTotal orderTotals;
    @AuraEnabled public List<ASDAC_OrderAssociationRequest> associationDetails;
    @AuraEnabled public List<ASDAC_PreviewResponseorderLines> orderLines = new List<ASDAC_PreviewResponseorderLines>();
    
    public class ASDAC_PreviewResponseorderLines{
        @AuraEnabled public String updateTime;
        @AuraEnabled public String orderLineId;
        @AuraEnabled public String orderLineType;
        @AuraEnabled public String fulfillmentType;
        @AuraEnabled public String fulfillmentService;
        @AuraEnabled public String quantity;
        @AuraEnabled public String productId;
        @AuraEnabled public String productType;
        @AuraEnabled public String productDescription;
        @AuraEnabled public String uom;
        @AuraEnabled public Boolean isBundle;
        @AuraEnabled public ASDAC_OrderLineRequest.OrderLineRelationship orderLineRelationship;
        @AuraEnabled public ASDAC_OrderTotal lineTotals = new ASDAC_OrderTotal();
        @AuraEnabled public List<LineAssociationDetails> associationDetails;
        @AuraEnabled public String reasonCode; 
    }
     public class LineAssociationDetails {
        @AuraEnabled
        public String associationType='SalesOrder';
        @AuraEnabled
        public Integer associatedLineId;
    }
   
}