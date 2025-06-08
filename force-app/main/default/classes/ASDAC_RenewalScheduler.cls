/***********************************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-16
* @Component Type               : Apex Class
* @component Name               : ASDAC_RenewalScheduler
* @description                  : ASDAC-8813 - GHS - DP SME - Auto-renew payload along with Payment authorization - 3
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-03-22
************************************************************************************************************************/
public with sharing class ASDAC_RenewalScheduler implements schedulable {
    
    
    /**********************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-17
* @Method Name                  : doCancellation
* @Modified By                  : Deepakshi
* @Modified Date		         : 2023-03-22
**********************************************************************************/
    public void execute(SchedulableContext sc){
        Boolean autoRenewalDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('DisableAutoRenewal').ASDAC_LoyaltySwitch__c;
        if(!autoRenewalDisable){
            ASDAC_SubscriptionAutoRenewalBatch objBatch = new ASDAC_SubscriptionAutoRenewalBatch();
            Database.executeBatch(objBatch,1); 
        }  
    }
    
}