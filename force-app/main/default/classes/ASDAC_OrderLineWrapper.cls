public with sharing class ASDAC_OrderLineWrapper {
  @AuraEnabled
  public Integer orderLineId { get; set; }
  @AuraEnabled
  public String orderLineType { get; set; }
  @AuraEnabled
  public String fulfillmentType { get; set; }
  @AuraEnabled
  public String omsStatus { get; set; }
  @AuraEnabled
  public String fulfillmentService { get; set; }
  @AuraEnabled
  public Boolean isBundle { get; set; }
  @AuraEnabled
  public Integer parentId { get; set; }
  @AuraEnabled
  public String productId { get; set; }
  @AuraEnabled
  public String productDescription { get; set; }
  @AuraEnabled
  public String productType { get; set; }
  @AuraEnabled
  public String productLink { get; set; }
  @AuraEnabled
  public String uom { get; set; }
  @AuraEnabled
  public Decimal quantity { get; set; }
  @AuraEnabled
  public String actionType { get; set; } // returnType? if type not applicable in any other action
  @AuraEnabled
  public String reason { get; set; }
  @AuraEnabled
  public String notes { get; set; }
  @AuraEnabled
  public Decimal discount { get; set; }
  @AuraEnabled
  public Datetime promisedDeliveryDate { get; set; }
  @AuraEnabled
  public List<OrderLineAssociation> associationDetails { get; set; }
  @AuraEnabled
  public Decimal refundableQuantity { get; set; }
  @AuraEnabled 
  public Boolean isCharitableProduct { get; set; }
  @AuraEnabled
  public String returnOrderId { get; set; }
 
  @AuraEnabled
  public Datetime promisedDeliveryDateMax {
    get {
      return promisedDeliveryDate?.addDays(3);
    }
  }

  @AuraEnabled
  public ASDAC_OrderTotal lineTotals { get; set; }
  @AuraEnabled
  public ASDAC_OrderContact shipToContact { get; set; }
  @AuraEnabled
  public ASDAC_OrderAddress shipToAddress { get; set; }

  public class OrderLineAssociation {
    @AuraEnabled public String associationType { get; set; }
    @AuraEnabled public Integer associatedLineId{ get; set; }
  }
}