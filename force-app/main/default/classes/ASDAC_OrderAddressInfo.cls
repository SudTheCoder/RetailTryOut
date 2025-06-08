public with sharing class ASDAC_OrderAddressInfo {
  @AuraEnabled
  public String id { get; set; }
  @AuraEnabled
  public Boolean isDefault { get; set; }
  @AuraEnabled
  public ASDAC_OrderContact contact { get; set; }
  @AuraEnabled
  public ASDAC_OrderAddress address { get; set; }
  @AuraEnabled
  public String type { get; set; }
  @AuraEnabled
  public Boolean isActive { get; set; }
}