public with sharing class ASDAC_OrderLineRequest {
  @AuraEnabled
  public Integer orderLineId;
  @AuraEnabled
  public String orderLineType;
  @AuraEnabled
  public String fulfillmentType;
  @AuraEnabled
  public String omsStatus;
  @AuraEnabled
  public String fulfillmentService;
  @AuraEnabled
  public Boolean isBundle;
  @AuraEnabled
  public OrderLineRelationship orderLineRelationship;
  @AuraEnabled
  public String productId;
  @AuraEnabled
  public String productType;
  @AuraEnabled
  public String productDescription;
  @AuraEnabled
  public String uom;
  @AuraEnabled
  public Decimal quantity;
  @AuraEnabled
  public String reasonCode;

  public Boolean partialFillAllowed = true;

  @AuraEnabled
  public CustomFields customFields;

  @AuraEnabled
  public OrderDateRanges dates;

  //added for return request
  @AuraEnabled
  public String updateUser;
  @AuraEnabled
  public ASDAC_OrderTotal lineTotals;

  @AuraEnabled
  public List<ASDAC_OrderAddressInfo> addressInfo;

  @AuraEnabled
  public List<OrderAssociation> associationDetails;

  @AuraEnabled
  public List<ASDAC_OrderDiscountRequest> discounts;

  @AuraEnabled
  public List<ASDAC_OrderCommentRequest> comments;

  public class OrderLineRelationship {
    @AuraEnabled
    public String relationshipType;
    @AuraEnabled
    public Integer relatedToOrderLineId;
  }

  public class CustomFields {
    @AuraEnabled
    public String itemPageUrl;
    @AuraEnabled
    public String returnType;
    @AuraEnabled
    public String returnReason;
    @AuraEnabled
    public String exchangeReason;
    @AuraEnabled
    public String returnNotes;
    @AuraEnabled
    public String exchangeNotes;
    @AuraEnabled
    public String returnReasonCode;
    @AuraEnabled
    public ASDAC_OrderRefundFraudWrapper fraud;
  }

  public class OrderDateRanges {
    @AuraEnabled
    public OrderDateRange requestedDeliveryDate;
  }

  public class OrderDateRange {
    @AuraEnabled
    public Datetime min;
    @AuraEnabled
    public Datetime max;
  }

  public class OrderAssociation {
    @AuraEnabled
    public String associationType;
    @AuraEnabled
    public Integer associatedLineId;
    @AuraEnabled
    public Decimal quantity;
    @AuraEnabled
    public String productId;
  }
}