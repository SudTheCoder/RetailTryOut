/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-05-31
* @description                  : Helper class for ASDAC_RecurringWebhookDetail class
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                31-May-2023      Created the class
***************************************************************************************************/
public with sharing class ASDAC_RecurringWebhookDetailHelper {
    public static void recurringSlotHelper(Id customerId,String skipSlotDate,Integer skippingreasonId,String templateId){
        Map<String,ASDAC_RecurringSlotSkippingCode__mdt> webhookCodes = ASDAC_RecurringSlotSkippingCode__mdt.getAll();
        String webhookReasonCodes =String.valueOf(skippingreasonId);
        List<Asset> asstList = New List<Asset>();
        if(webhookReasonCodes == webhookCodes.get('slotSeriesCancelled').ASDAC_SlotSkippingCode__c){
            asstList = [select Id,Status,seq_counter__c,Recurring_Slot_Id__c, Recurring_Slot_1__c, Recurring_Slot_2__c, Recurring_Slot_3__c,Is_1_skipped__c, Is_2_skipped__c, Is_3_skipped__c,Recurring_Slot_Start__c,Recurring_Slot_End__c,Account.PersonContactId,Account.personEmail,Account.firstName,ReasonCode__c,Recurring_Slot_Frequency__c,Recurring_Slot_Template_Id__c,Recurring_Slot_Status__c from Asset where Recurring_Slot_Template_Id__c = :templateId and Account.PersonContactId =:customerId and ReasonCode__c != :webhookCodes.get('slotSeriesCancelled').ASDAC_SlotSkippingCode__c WITH SECURITY_ENFORCED limit 1]; 
        }else{
            asstList = [Select Id,Status,seq_counter__c,Recurring_Slot_Id__c, Recurring_Slot_1__c, Recurring_Slot_2__c, Recurring_Slot_3__c,Is_1_skipped__c, Is_2_skipped__c, Is_3_skipped__c,Recurring_Slot_Start__c,Recurring_Slot_End__c,Account.PersonContactId,Account.personEmail,Account.firstName,ReasonCode__c,Recurring_Slot_Frequency__c,Recurring_Slot_Template_Id__c,Recurring_Slot_Status__c from Asset where Status ='Active' and Recurring_Slot_Status__c = 'Active' and Account.PersonContactId =:customerId WITH SECURITY_ENFORCED limit 1];
        }
        
        boolean webhookFlag = false;
        
        if(!asstList.isEmpty()){
            Asset asst = asstList[0];
            //If cancellation reason is auto cancelled than Update Recurring slot;
            if(skipSlotDate !=null && webhookReasonCodes == webhookCodes.get('autoskip').ASDAC_SlotSkippingCode__c){  
                updateSlots(asst,skipSlotDate);    
                
                updateRecurringSlotStatus(asst);
            } else if(webhookReasonCodes ==  webhookCodes.get('manualSkip').ASDAC_SlotSkippingCode__c && asst.ReasonCode__c == webhookReasonCodes){
                webhookReasonCodes = ''; 
                webhookFlag= true;
            }
            asst.ReasonCode__c = webhookReasonCodes;
            asst.Skipped_next_recurring_slot_date__c = asst.Recurring_Slot_Frequency__c=='1'? Date.ValueOf(skipSlotDate).addDays(7): Date.ValueOf(skipSlotDate).addDays(14);
            if(!test.isRunningTest()){
                update asst; 
            }
            if(webhookFlag){
                //Call future Method with assetid and code as parameter;
                updateReasonCode(asst.Id , String.valueOf(skippingreasonId));
            }
        }
    }
    public static void updateSlots(Asset asst,String skipSlotDate){
        date dateval = date.valueOf(skipSlotDate.substring(0,10));
        date slot1 = date.valueOf(String.valueOf((asst.Recurring_Slot_1__c)).substring(0,10));
        date slot2 = date.valueOf(String.valueOf((asst.Recurring_Slot_2__c)).substring(0,10));
        date slot3 = date.valueOf(String.valueOf((asst.Recurring_Slot_3__c)).substring(0,10));
        
        if(dateval==slot1){
            asst.Is_1_skipped__c = true;
        }else if(dateval==slot2){
            asst.Is_2_skipped__c = true;
        }else if(dateval==slot3){
            asst.Is_3_skipped__c = true;
        }
    }
    //Update Asset object with code 747-Manual Skip and 884-slotSeriesCancelled
    @future
    public static void updateReasonCode(String asstId, String reasonCode){
        try{
            Asset asst = [Select id,ReasonCode__c from asset where Id=:asstId WITH SECURITY_ENFORCED limit 1];
            asst.ReasonCode__c = reasonCode;
            update asst ;
        }catch(Exception e){
            System.debug('Error '+e.getMessage());
            ASDAC_Logger.logException(e, ASDAC_GlobalConstants.STRING_LOYALTY, 'Issue found', 'ASDAC_RecurringWebhookDetailHelper');
            ASDAC_Logger.writeLogsToDatabase();
        }
        
        
    }
    
    //Recurring slot status assigned
    public static void updateRecurringSlotStatus(Asset asst){
        if(((asst.Is_1_skipped__c == true && asst.Is_2_skipped__c==true && asst.Is_3_skipped__c==true) || (asst.seq_counter__c ==2 && asst.Is_1_skipped__c ==true) || (asst.seq_counter__c==1 && asst.Is_1_skipped__c == true && asst.Is_2_skipped__c == true)) && !Test.isRunningTest()){
            //Code added to cancel recurring slot
            System.enqueueJob(new ASDAC_RSNullifyBatch(asst));   
        }
    }
}