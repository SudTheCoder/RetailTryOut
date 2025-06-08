@isTest
public with sharing class ASDAC_TriggerVoucherEmailTest {
    public static final String MAILID = 'xyz@email.com';
    public static final String BUSINESS_AREA = 'George';
    User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
    
    @TestSetup
    static void createData(){
                User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + 'TestVoucher';
        insert ocsASDABaseUser;
        //Create Contact Record
        Contact con = new Contact(LastName='Niteesh');
        //Create Account Record.
        Account acc = new Account();
        System.runAs(ocsASDABaseUser) {
            String recTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
            acc.FirstName = 'Voucher';
            acc.LastName = 'TestVoucher';
            acc.Loginid__c ='test@asdatest.co.uk';
            acc.RecordTypeId = recTypeId;
            insert acc;
            
            //Create Case Record
            Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName().get('CustomerSupport').getRecordTypeId();
            case cs = new case();
            cs.ContactReasonLevel1__c = 'Loyalty & Rewards';
            cs.ContactReasonLevel2__c = 'Vouchers';
            cs.Status = 'Assigned';
            cs.Subject = 'Goodwill Voucher';
            cs.BusinessArea__c =BUSINESS_AREA;
            cs.RecordTypeId = devRecordTypeId;
            cs.ContactId = con.id;
            insert cs;
            
            //Create Goodwill Record
            Goodwill__c goodwillVal = new Goodwill__c();
            goodwillVal.Email__c=MAILID;
            goodwillVal.VoucherAmount__c = 20;
            goodwillVal.CaseId__c = cs.id;
            goodwillVal.Voucher_Code__c='NDJKDJHFEKJKEDF';
            goodwillVal.AccountId__c=acc.id;
            goodwillVal.BusinessArea__c =BUSINESS_AREA;
            goodwillVal.ReasonCode__c = 'Arrived Damaged or broken';
            insert goodwillVal;
        }
    }
    @isTest
    static void getVoucherCodeTest(){
        Goodwill__c gw = [Select id,Voucher_Code__c,VoucherAmount__c,AccountId__c,AccountId__r.Name,AccountId__r.Loginid__c,Email__c,AccountId__r.PersonContactId,AccountId__r.FirstName,ReasonCode__c from Goodwill__c limit 1];
        
        Test.setMock(HttpCalloutMock.class, new GetVoucherCodeMock());
        
        test.startTest(); 
        ASDAC_GoodWillWalletIdentity.ResponseWrapper voucherdetail= ASDAC_GetVoucherCode.getGeorgeVoucherCode(gw);
        System.assertEquals('NDJKDJHFEKJKEDF', voucherdetail.gift_certificate_code,'Error in result');
        test.stopTest();
    }
     @isTest
    static void georgeVoucherEmailTest(){
        Goodwill__c gw = [Select id,Voucher_Code__c,VoucherAmount__c,AccountId__c,AccountId__r.Name,AccountId__r.Loginid__c,Email__c,AccountId__r.PersonContactId,AccountId__r.FirstName,ReasonCode__c from Goodwill__c limit 1];
        
        Test.setMock(HttpCalloutMock.class, new ASDAC_TriggerVoucherEmailMockTest());
        
        test.startTest();

         ASDAC_TriggerVoucherEmail.sendVoucherEmail(gw.AccountId__c, 'xyz', 5, 'george');
        test.stopTest();
    }
      @isTest
    static void ghsVoucherEmailTest(){
        Goodwill__c gw = [Select id,Voucher_Code__c,VoucherAmount__c,AccountId__c,AccountId__r.Name,AccountId__r.Loginid__c,Email__c,AccountId__r.PersonContactId,AccountId__r.FirstName,ReasonCode__c from Goodwill__c limit 1];
        System.debug('gw: '+gw);
        Test.setMock(HttpCalloutMock.class, new ASDAC_TriggerVoucherEmailMockTest());
        
        test.startTest();
        
         ASDAC_TriggerVoucherEmail.sendVoucherEmail(gw.AccountId__c, null, 5, 'GHS');
        test.stopTest();
    }
    @isTest
    static void getVoucherTokenTest(){
        Test.setMock(HttpCalloutMock.class, new ASDAC_AuthorizeSFCCForVoucherMockTest());
        
        test.startTest();       
        String access_token = ASDAC_AuthorizeSFCCForVoucher.getMerkelAuthToken();
        System.assertEquals('f1fY_SmhFU5NgfHgF9VzDyMkuA0', access_token,'Error in result');
        test.stopTest();
    }
    
  
public class GetVoucherCodeMock implements HttpCalloutMock {
	 public HTTPResponse respond(HTTPRequest request) {
       String accesstoken = 'randomaccesstoken';  
        // Create a fake response
       String body ='{\n'+
    '"action": "OCAPIProxy-CreateGiftCertificate",\n'+
    '"queryString": "redirectFromInt=1&v=22_10",\n'+
    '"locale": "default",\n'+
    '"_v": "22.10",\n'+
    '"_type": "gift_certificate",\n'+
    '"_resource_state": "115c75a4763b4978861a02e4a5653579a63aeb68c7ccd2cab3c5ab25f4ef6dee",\n'+
    '"creation_date": "2022-11-25T07:30:08.678Z",\n'+
    '"enabled": true,\n'+
    '"last_modified": "2022-11-25T07:30:08.680Z",\n'+
    '"link": "https://aacd-024.sandbox.us01.dx.commercecloud.salesforce.com/s/-/dw/data/v22_10/sites/ASDA/gift_certificates/00007505_aacd_24",\n'+
    '"masked_gift_certificate_code": "***********KEDF",\n'+
    '"merchant_id": "00007505_aacd_24",\n'+
    '"recipient_email": "miroslava.malcheva@merkle.com",\n'+
    '"recipient_name": "Mira",\n'+
    '"status": "pending",\n'+
    '"transactions": [\n'+
        '{\n'+
            '"_type": "account_transaction",\n'+
            '"amount": {\n'+
                '"_type": "money",\n'+
                '"currency_mnemonic": "GBP",\n'+
                '"value": 20\n'+
            '},\n'+
            '"timestamp": "2022-11-25T07:30:08.679Z",\n'+
            '"type_code": "create"\n'+
        '}\n'+
    '],\n'+
    '"gift_certificate_code": "NDJKDJHFEKJKEDF",\n'+
    '"expiry_date": "2022-12-25T23:59:59.000Z"\n'+
'}\n';
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setHeader('Authorization', 'Bearer '+ accesstoken);
        response.setBody(body);
        response.setStatusCode(200);
        return response; 
    }
}
}