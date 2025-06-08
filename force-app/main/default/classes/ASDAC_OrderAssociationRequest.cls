public with sharing class ASDAC_OrderAssociationRequest {
  @AuraEnabled public String orgId { get; set; }
  @AuraEnabled public String sellingChannel{ get; set; }
  @AuraEnabled public String orderId{ get; set; }
  @AuraEnabled public String associationType{ get; set; }
  @AuraEnabled public Boolean copyPayment{ get; set; }
}