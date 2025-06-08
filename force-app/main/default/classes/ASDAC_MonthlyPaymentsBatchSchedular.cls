/***********************************************************************************************************************
* @author                       : Venkatesh Voleti
* @date                         : 2023-03-02
* @Component Type               : Apex Class
* @component Name               : ASDAC_MonthlyInstallmentPaymentsBatch Schedular
* @description                  : ASDAC-7358, ASDAC-8203 - GHS - DP SME - Monthly instalment payload along with Payment authorization
************************************************************************************************************************/

public class ASDAC_MonthlyPaymentsBatchSchedular implements Schedulable {
    
    public void execute(SchedulableContext scheduler) {
        Boolean monthlyInstallmentDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('DisableMonthlyInstallment').ASDAC_LoyaltySwitch__c;
        if(!monthlyInstallmentDisable){
            ASDAC_MonthlyInstallmentPaymentsBatch monthlyPaymentBatchJob = new ASDAC_MonthlyInstallmentPaymentsBatch();
            Database.executeBatch(monthlyPaymentBatchJob,1);
        }
    }
}