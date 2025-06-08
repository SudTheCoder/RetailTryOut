/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-03-06
* @description                  : schedule job to run every day 11:45 PM 
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                06-Mar-2023      Created the class
***************************************************************************************************/
public class ASDAC_ScheduleUpdateRecurringSlot implements Schedulable {
    public void execute(SchedulableContext sc){
        Boolean slotResetDisable = ASDAC_LoyaltyCodeEnablementSwitch__mdt.getInstance('RecurringSlotResetEnablement').ASDAC_LoyaltySwitch__c;
        if(!slotResetDisable){
            ASDAC_UpdateRecurringSlotBatch upr = new ASDAC_UpdateRecurringSlotBatch();
            database.executeBatch(upr); 
        }
    }	
}