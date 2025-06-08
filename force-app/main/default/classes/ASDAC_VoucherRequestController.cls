public with sharing class ASDAC_VoucherRequestController {
  @AuraEnabled(cacheable=true)
  public static List<ASDAC_VoucherAmount__mdt> getVoucherRecords() {
    return [
      SELECT ASDAC_MaximumAmount__c, ASDAC_VoucherAmt__c
      FROM ASDAC_VoucherAmount__mdt
    ];
  }

    @AuraEnabled(cacheable=true)
    public static Decimal getGoodWillLimit() {
        try {
            Id userId = UserInfo.getUserId();
            User usr = [SELECT Id, UserRole.Name FROM User WHERE Id=:userId];
            if(String.isNotBlank(usr.UserRole.Name)){
                Goodwill_RoleLimits__mdt gdWillMetaData = [SELECT Id, Job_Role__c, Goodwill_Limit__c FROM Goodwill_RoleLimits__mdt where Job_Role__c = :usr.UserRole.Name LIMIT 1];
                return gdWillMetaData.Goodwill_Limit__c;
            }
            return null;
            
        } catch (Exception exp) {
            throw new AuraHandledException(exp.getMessage());
        }
    }
}