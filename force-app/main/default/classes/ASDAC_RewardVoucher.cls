public with sharing class ASDAC_RewardVoucher {
    @AuraEnabled
    public String rewardVoucherId { get; set; }
    @AuraEnabled
    public Decimal amountUsed { get; set; }
}