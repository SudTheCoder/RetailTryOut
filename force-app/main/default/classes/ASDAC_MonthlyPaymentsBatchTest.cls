@isTest
public with sharing class ASDAC_MonthlyPaymentsBatchTest  {
    @testSetUp
    public static void dataSetup(){
        User ocsASDABaseUser = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        ocsASDABaseUser.userName = ocsASDABaseUser.userName + 'TestVoucher';
        insert ocsASDABaseUser;
        System.runAs(ocsASDABaseUser){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account objAccount = new Account(FirstName='Test',LastName = 'Account 1',Loginid__c='testEmail@asdatest.co.uk',RecordTypeID=recordTypeId);
            Insert objAccount;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Order objOrder = new Order(Name='Test Order 1',AccountId=ObjAccount.Id,EffectiveDate=system.today(),Status='Draft',Pricebook2Id = pricebookId);
            Insert objOrder;
            
            Product2 objProduct = new Product2(Name = 'TestProd1',ItemId__c = 'TEST',PlanDuration__c=6,NumberOfInstallments__c=6,isActive=true);
            insert objProduct;
            
            PricebookEntry pe = new PricebookEntry(UnitPrice=123, Product2Id = objProduct.Id, Pricebook2Id = pricebookId);
            Insert pe;
            
            OrderItem objOrderProduct = new OrderItem(OrderId = objOrder.Id,PricebookEntryId=pe.Id, UnitPrice=123, TotalLineAmount=123, Quantity=1);
            insert objOrderProduct;
            //Create ContactPointAddress
            ContactPointAddress cpa = new ContactPointAddress(AddressLine1__c ='123',AddressLine2__c='sdf',AddressLine3__c='dfc',City__c='testCity',Country='United Kingdom',CountryCode='GB',Country__c='GB',Name ='123, sdf, dfc, testCity, 201012');
            insert cpa;
            
            //Create Customer Card
            CustomerCard__c cc = new CustomerCard__c(AccountId__c=objAccount.id,AddressId__c = cpa.id,CardToken__c='4e4406aa-da7d-4d6f-bd69-cbbd5a8e6741',ExpiryDate__c ='02/2098',MaskedCardNumber__c='************4675',NameOnCard__c='Niteesh Kumart',CardBrand__c='1');        
            insert cc;
            
            List<Asset> objAssetlist = new List<Asset>();
            Asset objAsset = new Asset(status ='Active',Name='Test Asset 1',AccountId=objAccount.Id,loyaltyOrderNumber__c=objOrder.Id,Product2Id = objProduct.id,UsageEndDate = date.today().addyears(1).addDays(-1) ,PurchaseDate = date.today(), shopOrderNumber__c = 'TestShop123',Customer_Card__c=cc.id,Acquirer_Name__c ='ACQURERE',Payment_Id__c='12345',SchemeReferenceData__c='874764647',PSPID__c='nitkumar4',Payment_Product_Name__c='test123',Next_Payment_Date__c= date.today(),Migrated_Next_Payment_Date__c = date.today(),Auto_Renew__c = true);
             // Asset objAsset1 = new Asset(status ='Active',Name='Test Asset 3',AccountId=objAccount.Id,loyaltyOrderNumber__c=objOrder.Id,Product2Id = objProduct.id,UsageEndDate = date.today().addyears(1).addDays(-1) ,PurchaseDate = date.today(), shopOrderNumber__c = 'TestShop123',Customer_Card__c=cc.id,Acquirer_Name__c ='ACQURERE',Payment_Id__c='12345',SchemeReferenceData__c='874764647',PSPID__c='nitkumar4',Payment_Product_Name__c='test123',Next_Payment_Date__c= date.today().addmonths(1),isMigratedSubscription__c=true,Migrated_Next_Payment_Date__c = date.today(),Auto_Renew__c = true);
            //Asset objAsset2 = new Asset(status ='Active',Name='Test Asset 1',AccountId=objAccount.Id,loyaltyOrderNumber__c=objOrder.Id,Product2Id = objProduct.id,UsageEndDate = date.today().addyears(1).addDays(-1) ,PurchaseDate = date.today(), shopOrderNumber__c = 'TestShop123',Customer_Card__c=cc.id,Acquirer_Name__c ='ACQURERE',Payment_Id__c='12345',SchemeReferenceData__c='874764647',PSPID__c='nitkumar4',Payment_Product_Name__c='test123',DP_Cancellation_Type__c='Regular',Next_Payment_Date__c= date.today(),Migrated_Next_Payment_Date__c = date.today(),Auto_Renew__c = true);
            //objAssetlist.add(objAsset);objAssetlist.add(objAsset1);objAssetlist.add(objAsset2);
            //Insert objAssetlist;
            insert objAsset;//insert objAsset1;
        }
    }
    @isTest
    public static void testMonthlyPayment(){
        Asset asst = [SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,Customer_Card__r.CardBrand__c from Asset where Name = 'Test Asset 1' limit 1];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new monthlyPaymentsBatchMock());
        //String sch ='0 6 * * *'; 
        // String jobID = System.schedule('scheduleMonthly', sch,  new ASDAC_MonthlyPaymentsBatchSchedular());
          String CRON_EXP = '0 1 * * * ?';
             ASDAC_MonthlyPaymentsBatchSchedular scheduleMonthly = new ASDAC_MonthlyPaymentsBatchSchedular();
            System.schedule('Schedule AutoRenew Job every day', CRON_EXP, scheduleMonthly);
        Test.stopTest();
    }
    
        @isTest
    public static void testMonthlyPayment1(){
        Asset asst = [SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,Customer_Card__r.CardBrand__c from Asset where Name = 'Test Asset 1' limit 1];
        asst.isMigratedSubscription__c = true;
        asst.Migrated_Next_Payment_Date__c = date.today();
       asst.Next_Payment_Date__c = date.today().addMonths(1);
        update asst;
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new monthlyPaymentsBatchMock());

        ASDAC_MonthlyInstallmentPaymentsBatch monthlyPaymentBatchJob = new ASDAC_MonthlyInstallmentPaymentsBatch();
        Database.executeBatch(monthlyPaymentBatchJob,1);
        Test.stopTest();
    }
         @isTest
    public static void testMonthlyPayment2(){
        Asset asst = [SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,Customer_Card__r.CardBrand__c from Asset where Name = 'Test Asset 1' limit 1];
       asst.DP_Cancellation_Type__c ='Regular';
        update asst;
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new monthlyPaymentsBatchMock());
        //String sch ='0 6 * * *'; 
        // String jobID = System.schedule('scheduleMonthly', sch,  new ASDAC_MonthlyPaymentsBatchSchedular());
        ASDAC_MonthlyInstallmentPaymentsBatch monthlyPaymentBatchJob = new ASDAC_MonthlyInstallmentPaymentsBatch();
        Database.executeBatch(monthlyPaymentBatchJob,1);
        Test.stopTest();
    }
    
             @isTest
    public static void testMonthlyPayment4(){
        Asset asst = [SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,Customer_Card__r.CardBrand__c from Asset where Name = 'Test Asset 1' limit 1];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new monthlyPaymentsBatchMock());
        //String sch ='0 6 * * *'; 
        // String jobID = System.schedule('scheduleMonthly', sch,  new ASDAC_MonthlyPaymentsBatchSchedular());
        ASDAC_MonthlyInstallmentPaymentsBatch monthlyPaymentBatchJob = new ASDAC_MonthlyInstallmentPaymentsBatch(asst.Id);
        Database.executeBatch(monthlyPaymentBatchJob,1);
        Test.stopTest();
    }
    
    @isTest
    public static void testMonthlyRetryBatch(){
        Asset asst = [SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,Customer_Card__r.CardBrand__c from Asset where Name = 'Test Asset 1' limit 1];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new monthlyPaymentsBatchMock());
        //String sch ='0 6 * * *'; 
        // String jobID = System.schedule('scheduleMonthly', sch,  new ASDAC_MonthlyPaymentsBatchSchedular());
        List<Id> asstIds = new List<Id>{asst.id};
            ASDAC_MonthlyInstallmentRetryBatch.subscriptionMonthlyInstallment(new List<List<Id>>{asstIds});
        //ASDAC_MonthlyInstallmentRetryBatch monthlyPaymentBatchJob = new ASDAC_MonthlyInstallmentRetryBatch(asstIds);
       // Database.executeBatch(monthlyPaymentBatchJob,1);
        Test.stopTest();
    }
        
    @isTest
    public static void testMonthlymigratedRetryBatch(){
        Asset asst = [SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,Customer_Card__r.CardBrand__c from Asset where Name = 'Test Asset 1' limit 1];
        asst.isMigratedSubscription__c = true;
        asst.Payment_Id__c = null;
        asst.PSPID__c =null;
        update asst;
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new ASDAC_PaymentCalloutMockTest());
        //String sch ='0 6 * * *'; 
        // String jobID = System.schedule('scheduleMonthly', sch,  new ASDAC_MonthlyPaymentsBatchSchedular());
        List<Id> asstIds = new List<Id>{asst.id};
            ASDAC_MonthlyInstallmentRetryBatch.subscriptionMonthlyInstallment(new List<List<Id>>{asstIds});
        //ASDAC_MonthlyInstallmentRetryBatch monthlyPaymentBatchJob = new ASDAC_MonthlyInstallmentRetryBatch(asstIds);
       // Database.executeBatch(monthlyPaymentBatchJob,1);
        Test.stopTest();
    }
    
    @isTest
    public static void testPayemntResponseWrapper(){
         Asset asst = [SELECT Id,Status,DP_Cancellation_Type__c,isMigratedSubscription__c,Next_Payment_Date__c,Migrated_Next_Payment_Date__c,loyaltyOrderNumber__c,Customer_Card__r.CardBrand__c from Asset where Name = 'Test Asset 1' limit 1];
        asst.isMigratedSubscription__c = true;
        Test.startTest();
        ASDAC_PaymentResponseWrapper.worldlineAuthenticationRequest(asst, 'AutoRenew');
        Test.stopTest();
    }
    // get Order List Mock response - Success
    public class monthlyPaymentsBatchMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){            
            //  String body= getResponse()MonthlyPaymentsBatch;
            HttpResponse response = new HttpResponse(); 
            
            // response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);      
            return response;
        }
    }
}