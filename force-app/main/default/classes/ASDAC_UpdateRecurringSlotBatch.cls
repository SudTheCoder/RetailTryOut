/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-03-06
* @description                  : Batch class to reset Sequential count and update next three recurring slot datetime. 
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------a
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                06-Mar-2023      Created the class
***************************************************************************************************/
public class ASDAC_UpdateRecurringSlotBatch	 implements Database.Batchable<sObject>,Database.stateful {
    MAP<String,Integer> oldSkipFlags = new Map<String,Integer>{'truefalsetrue'=> 1,'truetruefalse'=> 0,'falsetruetrue'=> 2,'falsefalsefalse'=> 0,'falsefalsetrue'=> 1,'falsetruefalse'=> 0,'truefalsefalse'=>0};
        public Database.QueryLocator start(Database.BatchableContext bc) {	
            Date pdate = Date.Today().addDays(-1); 	
            Date ndate = Date.Today().addDays(1);
            System.debug('pdate and ndate :'+pdate+' '+ndate);
            return Database.getQueryLocator(	
                'select Id, Recurring_Slot_Id__c, Recurring_Slot_Frequency__c, Recurring_Slot_1__c, Recurring_Slot_2__c, Recurring_Slot_3__c, Is_1_skipped__c, Is_2_skipped__c, Is_3_skipped__c,seq_counter__c from Asset where Recurring_Slot_3__c > :pdate and Recurring_Slot_3__c < :ndate and Recurring_Slot_Status__c=\'Active\''	
            );	
        }	
    public void execute(Database.BatchableContext bc, List<Asset> assetList){	
        List<Asset> assetResetList = new List<Asset>();
        try{
            for(Asset ast :assetList){
                Asset asst = new Asset();
                string flagcheck = String.valueOf(ast.Is_1_skipped__c)+ast.Is_2_skipped__c+ast.Is_3_skipped__c;
                asst.id=ast.id;
                asst.Is_1_skipped__c = false;
                asst.Is_2_skipped__c = false;
                asst.Is_3_skipped__c = false;
                asst.Recurring_Slot_1_Order_Due_Flag__c = false;
                asst.Recurring_Slot_2_Order_Due_Flag__c = false;
                asst.Recurring_Slot_3_Order_Due_Flag__c = false;
                if(ast.Recurring_Slot_Frequency__c == '1'){
                    asst.Recurring_Slot_1__c = (ast.Recurring_Slot_3__c).addDays(7);
                }else if(ast.Recurring_Slot_Frequency__c =='2'){
                    asst.Recurring_Slot_1__c = (ast.Recurring_Slot_3__c).addDays(14);
                }
                asst.seq_counter__c =oldSkipFlags.get(flagcheck);
                assetResetList.add(asst);
            }
            if(assetResetList.isEmpty()!=true){
                Update assetResetList;
            }
        }catch(Exception e){
            System.debug('Error '+e.getMessage());
        }
    }	
    public void finish(Database.BatchableContext bc){	
    }	
}