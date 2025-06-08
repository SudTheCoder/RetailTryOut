@IsTest
public with sharing class ASDAC_SavingGurantee1Test {
    public static final String MAILID = 'xyz@email.com';
    User ocsCollBPO = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
    @testsetup
    static void testsetup() {
        Profile objProfile = [Select id,Name from Profile where Name = 'System Administrator'];
        User objUser = new User(Username = 'recurringslot@asdatest.co.uk',ProfileId = objProfile.Id ,Alias = 'test123',Email = 'test123@asdatest.co.uk',EmailEncodingKey = 'UTF-8',LastName = 'McTesty', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',LanguageLocaleKey = 'en_US');
        insert objUser;
        
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + 'TestVoucher';
        insert ocsASDABaseUser;
        System.runAs(ocsASDABaseUser){
            Account objAccount = new Account();
            objAccount.Name = 'DG Test';
            objAccount.Loginid__c ='dg@asdatest.co.uk';
            insert objAccount;           
            
            Contact con = new Contact(LastName='Deepakshi');
            
            Account acc = new Account();
            String RecTypeId= [select Id from RecordType where (Name='Person Account') and (SobjectType='Account')].Id;
            acc.FirstName = 'Test';
            acc.LastName = 'TestVoucher';
            acc.Loginid__c ='test@asdatest.co.uk';
            acc.RecordTypeId = RecTypeId;
            insert acc;
            
            Contact objContact = new Contact();
            objContact.LastName = 'DG Test';
            objContact.AccountId = objAccount.Id;
            insert objContact; 
            
            Order objOrder = new Order();
            objOrder.AccountId = acc.Id;
            objOrder.EffectiveDate = system.today().addYears(1);
            objOrder.Status = 'Draft';
            insert objOrder;
            
            Product2 objProd = new Product2(Name = 'TestProd1',ItemId__c = '6000035774',NumberOfInstallments__c = 12,PassGuarantee__c = true,PlanPrice__c = 72);
            insert objProd;
            
            List<Asset> asstlist = new List<Asset>();
            Asset objAsset = new Asset();
            objAsset.Product2Id=objProd.id;
            objAsset.Name = 'TestCancelled';
            objAsset.AccountId = acc.Id;
            objAsset.ContactId = acc.PersonContactId;
            objAsset.PurchaseDate =  System.today().adddays(-7);
            objAsset.UsageEndDate = System.today().addyears(1).adddays(-8);
            objAsset.status = 'Cancelled';
            objAsset.isMigratedSubscription__c = false;
            objAsset.Is_Saving_Guarantee_Issued__c = false;
            insert objAsset;
            
        }  
    }
    
    @isTest
    static void testGetOrderList() {
        
        Test.setMock(HttpCalloutMock.class, new getOrderListMock());
        Asset objAsset = [SELECT Refund_SavingGuranteeAmount__c,Product2Id,AccountId,ContactId,PurchaseDate,UsageEndDate,status,isMigratedSubscription__c,Migrated_Savings__c FROM Asset WHERE Name = : 'TestCancelled'];
        Test.startTest();
        Decimal totalDiscountOnDelivery =0;
        Boolean DeliveryPassUsedFlag = false;
        ASDAC_SavingGurantee.dpSavinngGurantee(new List<Id>{ objAsset.Id });
        ID jobId = System.enqueueJob(new ASDAC_GetOrderList(objAsset));
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobId];
        Assert.areEqual(0,jobInfo.NumberOfErrors,'getOrder Successfully Quened');
        Test.stopTest();
        
    }
    @isTest
    static void testDPCancelledSavinngGurantee() {
        
        Asset objAsset = [SELECT Refund_SavingGuranteeAmount__c,Product2Id,AccountId,ContactId,PurchaseDate,UsageEndDate,status,isMigratedSubscription__c,Product2.PassGuarantee__c,Product2.PlanPrice__c,Migrated_Savings__c FROM Asset WHERE Name = : 'TestCancelled'];
        Test.startTest();
        Decimal totalDiscountOnDelivery =0;
        Boolean DeliveryPassUsedFlag = false;
        String body= getResponse();
        ASDAC_LoyaltyGetOrderListWrapper response = (ASDAC_LoyaltyGetOrderListWrapper)System.JSON.deserialize(body, ASDAC_LoyaltyGetOrderListWrapper.class);
        ID jobId = System.enqueueJob(new ASDAC_SavingGurantee(response,objAsset));
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
        Assert.areEqual(0,jobInfo.NumberOfErrors,'Cancelled Successfully Quened');
        system.debug('jobInfoCancelled : '+jobInfo);
        Test.stopTest();
    }
    
    @isTest
    static void testDPCancelledSGCP() {
        
        Asset objAsset = [SELECT Refund_SavingGuranteeAmount__c,Product2Id,AccountId,ContactId,PurchaseDate,UsageEndDate,status,isMigratedSubscription__c,Product2.PassGuarantee__c,Product2.PlanPrice__c,Migrated_Savings__c FROM Asset WHERE Name = : 'TestCancelled'];
        Test.startTest();
        Decimal totalDiscountOnDelivery =0;
        Boolean DeliveryPassUsedFlag = false;
        String body= getResponse1();
        ASDAC_LoyaltyGetOrderListWrapper response = (ASDAC_LoyaltyGetOrderListWrapper)System.JSON.deserialize(body, ASDAC_LoyaltyGetOrderListWrapper.class);
        ID jobId = System.enqueueJob(new ASDAC_SavingGurantee(response,objAsset));
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
        Assert.areEqual(0,jobInfo.NumberOfErrors,'Cancelled Successfully Quened');
        system.debug('jobInfoCancelled : '+jobInfo);
        Test.stopTest();
    }
    @isTest
    static void testDPExpiredSavinngGurantee() {
        
        Asset objAsset = [SELECT Refund_SavingGuranteeAmount__c,Product2Id,AccountId,ContactId,PurchaseDate,UsageEndDate,status,isMigratedSubscription__c,Product2.PassGuarantee__c,Product2.PlanPrice__c,Is_Saving_Guarantee_Issued__c,Migrated_Savings__c FROM Asset WHERE Name = : 'TestCancelled'];
        objAsset.Status = 'Expired';
        update objAsset;
        Test.startTest();
        Decimal totalDiscountOnDelivery =0;
        Boolean DeliveryPassUsedFlag = false;
        String body= getResponse();
        ASDAC_LoyaltyGetOrderListWrapper response = (ASDAC_LoyaltyGetOrderListWrapper)System.JSON.deserialize(body, ASDAC_LoyaltyGetOrderListWrapper.class);
        ID jobId = System.enqueueJob(new ASDAC_SavingGurantee(response,objAsset));
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobId];
        Assert.areEqual(0,jobInfo.NumberOfErrors,'Expired Successfully Quened');
        Test.stopTest();
    }
    
        @isTest
    static void testDPMExpiredSavinngGurantee() {
        
        Asset objAsset = [SELECT Refund_SavingGuranteeAmount__c,Product2Id,AccountId,ContactId,PurchaseDate,UsageEndDate,status,isMigratedSubscription__c,Product2.PassGuarantee__c,Product2.PlanPrice__c,Is_Saving_Guarantee_Issued__c,Migrated_Savings__c FROM Asset WHERE Name = : 'TestCancelled'];
        objAsset.Status = 'Expired';
        objAsset.isMigratedSubscription__c = true;
        objAsset.Migrated_Savings__c = 2;
        update objAsset;
        Test.startTest();
        Decimal totalDiscountOnDelivery =0;
        Boolean DeliveryPassUsedFlag = false;
        String body= getResponse();
        ASDAC_LoyaltyGetOrderListWrapper response = (ASDAC_LoyaltyGetOrderListWrapper)System.JSON.deserialize(body, ASDAC_LoyaltyGetOrderListWrapper.class);
        ID jobId = System.enqueueJob(new ASDAC_SavingGurantee(response,objAsset));
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobId];
        Assert.areEqual(0,jobInfo.NumberOfErrors,'Expired Successfully Quened');
        Test.stopTest();
    }
    
    @isTest
    static void testDPExceptionSavinngGurantee() {       
          Asset objAsset = [SELECT Product2Id,AccountId,ContactId,PurchaseDate,UsageEndDate,status,isMigratedSubscription__c,Product2.PassGuarantee__c,Product2.PlanPrice__c,Migrated_Savings__c FROM Asset WHERE Name = : 'TestCancelled'];
        Test.startTest();
        Decimal totalDiscountOnDelivery =0;
        Boolean DeliveryPassUsedFlag = false;
        String body= getResponse1();
        ASDAC_LoyaltyGetOrderListWrapper response = (ASDAC_LoyaltyGetOrderListWrapper)System.JSON.deserialize(body, ASDAC_LoyaltyGetOrderListWrapper.class);
        ID jobId = System.enqueueJob(new ASDAC_SavingGurantee(response,objAsset));
        AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
        Assert.areEqual(0,jobInfo.NumberOfErrors,'Cancelled Successfully Quened');
        Test.stopTest();
    }
    @isTest
    static void testDPBulkExpiredSavinngGurantee() {
        
         Asset objAsset = [SELECT Refund_SavingGuranteeAmount__c,Product2Id,AccountId,ContactId,PurchaseDate,UsageEndDate,status,isMigratedSubscription__c,Product2.PassGuarantee__c,Product2.PlanPrice__c,Migrated_Savings__c FROM Asset WHERE Name = 'TestCancelled' limit 1];
        Asset asst =new Asset(
             Product2Id=objAsset.Product2Id,
            Name = 'TestCancelled',
            AccountId = objAsset.AccountId,
            ContactId = objAsset.ContactId,
            PurchaseDate =  System.today().adddays(-7),
            UsageEndDate = System.today().addyears(1).adddays(-8),
            status = 'Expired',
            isMigratedSubscription__c = false
        );
			insert asst;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new getOrderListMock());
        ASDAC_GetOrderListBatch orderList = new ASDAC_GetOrderListBatch(new List<Id>{ objAsset.Id});
        Database.executeBatch(orderList,1);
        Assert.isNotNull(objAsset,'Success');
        Test.stopTest();
    }
    
    
    // get Order List Mock response - Success
    public class getOrderListMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){            
            String body= getResponse();
            HttpResponse response = new HttpResponse(); 
            
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);      
            return response;
        }
    }
    public static String getResponse(){
        String body= ' {\n'+
            '"startIndex": 0,\n'+
            '"count": 148,\n'+
            '"totalCount": 148,\n'+
            '"data": [\n'+
            '{\n'+
            '"customerId": "0038E00001UzDZrQAN",\n'+
            '"orderId": "0700000003028",\n'+
            '"orderFulfilmentType": "GHS_CNC",\n'+
            '"fulfillmentService": "STANDARD",\n'+
            '"sellingChannel": "ASDA_GROCERIES",\n'+
            '"storeAddress": "4600",\n'+
            '"orderStatus": "SETTLED",\n'+
            '"totalAmount": 230.0,\n'+
            '"orderDate": "'+date.today().adddays(10)+'",\n'+
            '"deliveryDate": "2024-01-02T10:40:22Z",\n'+
            '"deliveryPassId": "312dwqd32r2wfedqw",\n'+
            '"deliveryPassUsed": true,\n'+
            '"actualPrice": 10,\n'+
            '"discountedPrice": 5,\n'+
            '"numberOfItems": 1,\n'+
            '"updateTime": "2024-01-02T08:57:07Z"\n'+
            '}\n'+
            '],\n'+
            '"numberOfOrderDPUsed": 0\n'+
            '}';
        return body;
    }
    public static String getResponse1(){
        String body= ' {\n'+
            '"startIndex": 0,\n'+
            '"count": 148,\n'+
            '"totalCount": 148,\n'+
            '"data": [\n'+
            '{\n'+
            '"customerId": "0038E00001UzDZrQAN",\n'+
            '"orderId": "0700000003028",\n'+
            '"orderFulfilmentType": "GHS_CNC",\n'+
            '"fulfillmentService": "STANDARD",\n'+
            '"sellingChannel": "ASDA_GROCERIES",\n'+
            '"storeAddress": "4600",\n'+
            '"orderStatus": "SETTLED",\n'+
            '"totalAmount": 230.0,\n'+
            '"orderDate": "'+date.today().adddays(1)+'",\n'+
            '"deliveryDate": "2024-01-02T10:40:22Z",\n'+
            '"deliveryPassId": "312dwqd32r2wfedqw",\n'+
            '"deliveryPassUsed": false,\n'+
            '"actualPrice": 10,\n'+
            '"discountedPrice": 0,\n'+
            '"numberOfItems": 1,\n'+
            '"updateTime": "2024-01-02T08:57:07Z"\n'+
            '}\n'+
            '],\n'+
            '"numberOfOrderDPUsed": 0\n'+
            '}';
        return body;
    }
    
}