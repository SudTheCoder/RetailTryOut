public with sharing class ASDAC_OrderContact {
  @AuraEnabled
  public String firstName { get; set; }
  @AuraEnabled
  public String middleName { get; set; }
  @AuraEnabled
  public String lastName { get; set; }
  @AuraEnabled
  public transient String name {
    get {
      List<String> allNames = new List<String> { firstName, middleName, lastName };
      List<String> names = new List<String>();
      for (String name : allNames) {
        if (String.isNotBlank(name)) {
          names.add(name);
        }
      }
      return String.join(names, ' ');
    }
  }
  @AuraEnabled
  public String phone { get; set; }
  @AuraEnabled
  public String email { get; set; }
}