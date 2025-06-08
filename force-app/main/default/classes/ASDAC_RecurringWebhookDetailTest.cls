/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2023-03-06
* @description                  : Test class for ASDAC_RecurringWebhookDetail,ASDAC_UpdateRecurringSlot and ASDAC_ScheduleUpdateRecurringSlot
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                06-Mar-2023      Created the class
***************************************************************************************************/
@isTest
public with sharing class ASDAC_RecurringWebhookDetailTest {
    public static final string autoskip = 'auto';
    public static	void recurringWebhookDetailTestsetup(Id assetId,datetime dateval,id customerId,String type){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();      
        response.statusCode =200;
        response.responseBody = Blob.valueOf(Json.serialize(new ASDAC_RecurringWebhookDetail.SFDCResponse('Success','Processed Successfully'))) ;
        RestContext.response = response;
        request.requestUri ='https://asdastores2022--loyaltydev.sandbox.my.salesforce.com/services/data/v54.0/sobjects/Asset/'+assetId;
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        String jsonbody = getRequestBody(dateval,customerId,type);
        request.requestBody = Blob.valueOf(jsonbody);
        RestContext.request = request;
    }
    @isTest
    public static void recurringWebhookDetailTest(){
        Asset asstval = [Select id,Recurring_Slot_3__c,Account.PersonContactId,Recurring_Slot_Status__c,Is_1_skipped__c,Is_2_skipped__c,Is_3_skipped__c from asset where Recurring_Slot_Id__c='0001' limit 1];
        recurringWebhookDetailTestsetup(asstval.id,asstval.Recurring_Slot_3__c,asstval.Account.PersonContactId,autoskip);
       Test.startTest();
        ASDAC_RecurringWebhookDetail.handleSkippingslotWebhook();
        system.assertEquals('Active',asstval.Recurring_Slot_Status__c , 'Success');
        Test.stopTest();
    }
    @isTest
    public static void recurringWebhookDetailTest1(){
        Asset asstval = [Select id,Recurring_Slot_2__c,Recurring_Slot_3__c,Recurring_Slot_Status__c,Account.PersonContactId,Is_1_skipped__c,Is_2_skipped__c,Is_3_skipped__c from asset where Recurring_Slot_Id__c='0002' limit 1];
        recurringWebhookDetailTestsetup(asstval.id,asstval.Recurring_Slot_2__c,asstval.Account.PersonContactId,autoskip);
        Test.startTest();
        ASDAC_RecurringWebhookDetail.handleSkippingslotWebhook();
        system.assertEquals('Active',asstval.Recurring_Slot_Status__c , 'Success');
        Test.stopTest();
    }
     @isTest
    public static void recurringWebhookDetailTest2(){
        Asset asstval = [Select id,Recurring_Slot_1__c,Recurring_Slot_2__c,Account.PersonContactId,Recurring_Slot_Status__c,Is_1_skipped__c,Is_2_skipped__c,Is_3_skipped__c from asset where Recurring_Slot_Id__c='0003' limit 1];
        system.debug('asstval: '+asstval);
        recurringWebhookDetailTestsetup(asstval.id,asstval.Recurring_Slot_1__c,asstval.Account.PersonContactId,autoskip);
        Test.startTest();
        ASDAC_RecurringWebhookDetail.handleSkippingslotWebhook();
        system.assertEquals('Active',asstval.Recurring_Slot_Status__c , 'Success');
        Test.stopTest();
    }
         @isTest
    public static void recurringWebhookDetailExceptionTest(){
        Asset asstval = [Select id,Recurring_Slot_1__c,Recurring_Slot_2__c,Account.PersonContactId,Recurring_Slot_Status__c,Is_1_skipped__c,Is_2_skipped__c,Is_3_skipped__c from asset where Recurring_Slot_Id__c='0004' limit 1];
        system.debug('asstval: '+asstval);
        recurringWebhookDetailTestsetup(asstval.id,asstval.Recurring_Slot_1__c,asstval.Account.PersonContactId,autoskip);
        Test.startTest();
        ASDAC_RecurringWebhookDetail.handleSkippingslotWebhook();
        system.assertEquals('Active',asstval.Recurring_Slot_Status__c , 'Success');
        Test.stopTest();
    }
             @isTest
    public static void recurringWebhookDetailExceptionTest1(){
        Asset asstval = [Select id,Recurring_Slot_1__c,Recurring_Slot_2__c,Account.PersonContactId,Recurring_Slot_Status__c,Is_1_skipped__c,Is_2_skipped__c,Is_3_skipped__c from asset where Recurring_Slot_Id__c='0003' limit 1];
        system.debug('asstval: '+asstval);
        recurringWebhookDetailTestsetup(asstval.id,asstval.Recurring_Slot_1__c,asstval.Account.PersonContactId,'cancelled');
        Test.startTest();
        ASDAC_RecurringWebhookDetail.handleSkippingslotWebhook();
        system.assertEquals('Active',asstval.Recurring_Slot_Status__c , 'Success');
        Test.stopTest();
    }
     @isTest
    public static void recurringWebhookDetailManualTest(){
        Asset asstval = [Select id,Recurring_Slot_1__c,Recurring_Slot_2__c,Account.PersonContactId,Recurring_Slot_Status__c,Is_1_skipped__c,Is_2_skipped__c,Is_3_skipped__c from asset where Recurring_Slot_Id__c='0005' limit 1];
        system.debug('asstval: '+asstval);
        recurringWebhookDetailTestsetup(asstval.id,asstval.Recurring_Slot_1__c,asstval.Account.PersonContactId,'manual');
        Test.startTest();
        ASDAC_RecurringWebhookDetail.handleSkippingslotWebhook();
        system.assertEquals('Active',asstval.Recurring_Slot_Status__c , 'Success');
        Test.stopTest();
    }
    @isTest
    public static void updateRecurringSlotBatchTest(){
		Test.startTest();
        ASDAC_ScheduleUpdateRecurringSlot recurringResetjob = new ASDAC_ScheduleUpdateRecurringSlot();
		String sch = '0 45 11 * * ?';
		String jobID = System.schedule('Reset recurring slot next days', sch, recurringResetjob);
        system.assertNotEquals(null,jobID , 'Success');
        Test.stopTest();
    }
   
    @testSetup
    public static void createAssetRecord() {
        //Create Person Account Record
        RecordType myRecordType = [select id from RecordType where SobjectType='Account' AND IsPersonType=True limit 1];
        List<Account> acclist = new List<Account>();
            for(Integer i=0;i<4;i++){
               Account acc = new Account(FirstName='test',LastName='Acc'+i,Recordtypeid=myRecordType.Id, Loginid__c='test'+i+'@asdatest.co.uk');  
                acclist.add(acc);
            }
        insert acclist;
        List<Asset> asstlist = new List<Asset>();
        Asset asst = new Asset(
            Name='Test record',
            Status='Active',
            Recurring_Slot_Id__c='0001',
            Recurring_Slot_Frequency__c='1',
            seq_counter__c=0,
            Recurring_Slot_Status__c = 'Active',
            Recurring_Slot_Start__c=date.today().addDays(-14),
            Recurring_Slot_1__c=date.today().addDays(-14),
            Recurring_Slot_End__c=date.today().addDays(90),
             Is_1_skipped__c = true,
            Is_2_skipped__c = true,
            AccountId = acclist[0].Id);
         Asset asst1 = new Asset(
            Name='Test record1',
            Status='Active',
            Recurring_Slot_Id__c='0002',
            Recurring_Slot_Frequency__c='2',
             Recurring_Slot_Template_Id__c ='123',
            seq_counter__c=1,
            Recurring_Slot_Start__c=date.today().addDays(-28),
            Recurring_Slot_1__c=date.today().addDays(-28),
            Recurring_Slot_End__c=date.today().addDays(90),
             Recurring_Slot_Status__c = 'Active',
            Is_1_skipped__c = true,
            AccountId = acclist[1].Id);
        Asset asst2 = new Asset(
            Name='Test record2',
            Status='Active',
            Recurring_Slot_Id__c='0003',
            Recurring_Slot_Frequency__c='1',
            Recurring_Slot_Template_Id__c ='123',
            seq_counter__c=2,
            Recurring_Slot_Start__c=date.today().addDays(-14),Recurring_Slot_Status__c = 'Active',
            Recurring_Slot_1__c=date.today().addDays(-14),
            Recurring_Slot_End__c=date.today().addDays(90),
            AccountId = acclist[2].Id);
         Asset asst3 = new Asset(
            Name='Test record3',
            Status='Cancelled',
            Recurring_Slot_Id__c='0004',
            Recurring_Slot_Frequency__c='1',
             Recurring_Slot_Template_Id__c ='123',
            seq_counter__c=2,
             Recurring_Slot_Status__c = 'Active',
            Recurring_Slot_Start__c=date.today().addDays(-14),
            Recurring_Slot_1__c=date.today().addDays(-14),
            Recurring_Slot_End__c=date.today().addDays(90),
         	AccountId = acclist[3].Id);
         Asset asst4 = new Asset(
            Name='Test record4',
            Status='Active',
            Recurring_Slot_Id__c='0005',
            Recurring_Slot_Frequency__c='1',
            Recurring_Slot_Template_Id__c ='123',
            seq_counter__c=2,
             ReasonCode__c = '747',
             Recurring_Slot_Status__c = 'Active',
            Recurring_Slot_Start__c=date.today().addDays(-14),
            Recurring_Slot_1__c=date.today().addDays(-14),
            Recurring_Slot_End__c=date.today().addDays(90),
         	AccountId = acclist[3].Id);
        asstlist.add(asst);
        asstlist.add(asst1);
        asstlist.add(asst2);
        asstlist.add(asst3);
        asstlist.add(asst4);
        insert asstlist;
    }
    public static String getRequestBody(datetime dateval,id customerId,String type){
        Map<String,ASDAC_RecurringSlotSkippingCode__mdt> webhookCodes = ASDAC_RecurringSlotSkippingCode__mdt.getAll();
        String  jsonbody = '{ "task": {"external_id": "BRNGG-3412207264887","cancelled_at": "2023-04-03T10:06:11.000Z","recurrent_task_template_id": "123","customer": {"external_id": "'+customerId+'"},"way_points": [{"position": 1, "no_later_than": null,';
        if(type=='manual'){
            jsonbody+=  '"no_earlier_than": null}, {"position": 2,"no_later_than": "'+dateval.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'","no_earlier_than": "'+dateval.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'" } ],"task_cancellation_reason": {"id": 576174,"reason_to_cancel_task": {"id": '+webhookCodes.get('manualSkip').ASDAC_SlotSkippingCode__c+'}}},"webhook_type": "task_cancelled","merchant_id": 60470}'; 
        }else if(type=='cancelled'){
            jsonbody+=  '"no_earlier_than": null}, {"position": 3,"no_later_than": "'+dateval.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'","no_earlier_than": "'+dateval.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'" } ],"task_cancellation_reason": {"id": 576174,"reason_to_cancel_task": {"id": '+webhookCodes.get('slotSeriesCancelled').ASDAC_SlotSkippingCode__c+'}}},"webhook_type": "task_cancelled","merchant_id": 60470}'; 
        }else{
            jsonbody+=  '"no_earlier_than": null}, {"position": 2,"no_later_than": "'+dateval.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'","no_earlier_than": "'+dateval.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'" } ],"task_cancellation_reason": {"id": 576174,"reason_to_cancel_task": {"id": '+ webhookCodes.get('autoskip').ASDAC_SlotSkippingCode__c+'}}},"webhook_type": "task_cancelled","merchant_id": 60470}';
        }
        
        
        system.debug('jsobbody : '+jsonbody);
        
        return jsonbody;    
    }
}