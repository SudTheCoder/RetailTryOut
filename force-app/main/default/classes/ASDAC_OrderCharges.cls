public with sharing class ASDAC_OrderCharges {
  
  @AuraEnabled
  public String name { get; set; }
  @AuraEnabled
  public String accountingType { get; set; }
  @AuraEnabled
  public String category { get; set; }
  @AuraEnabled
  public String referenceId { get; set; }
  @AuraEnabled
  public String referenceType { get; set; }
  @AuraEnabled
  public Decimal amount { get; set; }
  @AuraEnabled
  public Integer coefficient { get; set; }
  @AuraEnabled
  public Decimal invoicedAmount { get; set; }
  @AuraEnabled
  public Boolean isRefundable { get; set; }
  @AuraEnabled
  public List<Integer> appliesToLines { get; set; }
}