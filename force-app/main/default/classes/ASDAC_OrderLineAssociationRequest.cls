public with sharing class ASDAC_OrderLineAssociationRequest {
    @AuraEnabled public String associationType { get; set; }
    @AuraEnabled public Integer associatedLineId{ get; set; }
}