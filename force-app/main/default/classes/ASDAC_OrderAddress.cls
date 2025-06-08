public with sharing class ASDAC_OrderAddress {
  @AuraEnabled
  public String addressLine1 { get; set; }
  @AuraEnabled
  public String addressLine2 { get; set; }
  @AuraEnabled
  public String city { get; set; }
  @AuraEnabled
  public String state { get; set; }
  @AuraEnabled
  public String country { get; set; }
  @AuraEnabled
  public String zipCode { get; set; }
  @AuraEnabled
  public Decimal latitude { get; set; }
  @AuraEnabled
  public Decimal longitude { get; set; }
}