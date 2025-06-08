/**********************************************************************************
* @author                       : Niteesh Kumar
* @date                         : 2024-07-25
* @description                  : ASDAC-21425- Batch class for BillingSchedule creation for DP data migration Test
**********************************************************************************/
/*
* Modification Log:
*---------------------------------------------------------------------------------------------------
* Developer                     Date            Description
*---------------------------------------------------------------------------------------------------
* Niteesh Kumar                25-July-2025      Created the class
***************************************************************************************************/
@isTest
public class ASDAC_CreateBillingScheduleBatchTest {
    @testSetUp
    public static void dataSetup(){
        User  dpMigration = ASDAC_TestDataUtility.createUsers(1, false, 'System Administrator')[0];
        dpMigration.userName = dpMigration.userName + 'dpMigration';
        dpMigration.FirstName = 'DeliveryPass';
        dpMigration.LastName = 'Migration User';
        insert dpMigration;
        System.runAs(dpMigration){
            String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
            Account objAccount = new Account(FirstName='Test',LastName = 'Account 1',Loginid__c='testEmail@gmail.com',RecordTypeID=recordTypeId);
            Insert objAccount;
            
            Id pricebookId = Test.getStandardPricebookId();
            
            Order objOrder = new Order(Name='Test Order 1',AccountId=ObjAccount.Id,EffectiveDate=system.today(),Status='Draft',Pricebook2Id = pricebookId);
            Insert objOrder;
            
            Product2 objProduct = new Product2(Name = 'TestProd1',ItemId__c = 'TEST',PlanDuration__c=6,NumberOfInstallments__c=6,isActive=true);
            insert objProduct;
            
            PricebookEntry pe = new PricebookEntry(UnitPrice=123, Product2Id = objProduct.Id, Pricebook2Id = pricebookId);
            Insert pe;
            
            OrderItem objOrderProduct = new OrderItem(OrderId = objOrder.Id,PricebookEntryId=pe.Id, UnitPrice=123, TotalLineAmount=123, Quantity=1, Description='Retry BS');
            insert objOrderProduct;
            //Create ContactPointAddress
            ContactPointAddress cpa = new ContactPointAddress(AddressLine1__c ='123',AddressLine2__c='sdf',AddressLine3__c='dfc',City__c='testCity',Country='United Kingdom',CountryCode='GB',Country__c='GB',Name ='123, sdf, dfc, testCity, 201012');
            insert cpa;
            
            //Create Customer Card
            CustomerCard__c cc = new CustomerCard__c(AccountId__c=objAccount.id,AddressId__c = cpa.id,CardToken__c='4e4406aa-da7d-4d6f-bd69-cbbd5a8e6741',ExpiryDate__c ='02/98',MaskedCardNumber__c='************4675',NameOnCard__c='Niteesh Kumart',CardBrand__c='1');        
            insert cc;
            
            Asset objAsset = new Asset(status ='Active',Name='Test Asset 1',AccountId=objAccount.Id,loyaltyOrderNumber__c=objOrder.Id,Product2Id = objProduct.id,UsageEndDate = date.today().addyears(1).addDays(-1) ,PurchaseDate = date.today(), shopOrderNumber__c = 'TestShop123',Customer_Card__c=cc.id,Acquirer_Name__c ='ACQURERE',Payment_Id__c='12345',SchemeReferenceData__c='874764647',PSPID__c='nitkumar4',Payment_Product_Name__c='test123',Next_Payment_Date__c= date.today(),Migrated_Next_Payment_Date__c = date.today(),Auto_Renew__c = true);
            insert objAsset;
        }
    }
    @isTest
    public static void createBillingScheduleBatchTest(){
        OrderItem orderProduct = [SELECT Id,OrderId,Description from OrderItem where Description = 'Retry BS' limit 1];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new CreateBillingScheduleBatchMock());
        ASDAC_CreateBillingScheduleBatch bsbatch = new ASDAC_CreateBillingScheduleBatch();
        Database.executeBatch(bsbatch,25);
        Test.stopTest();
    }
    @isTest
    public static void createBillingScheduleBatchTest1(){
        OrderItem orderProduct = [SELECT Id,OrderId,Description from OrderItem where Description = 'Retry BS' limit 1];
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class , new CreateBillingScheduleBatchMock());
        List<Id> ids = new List<Id>{'8023G0000002ipWQAQ'};
            ASDAC_CreateBillingScheduleBatch bs = new ASDAC_CreateBillingScheduleBatch(ids);
        database.executeBatch(bs,25);
        Test.stopTest();
    }
    public class CreateBillingScheduleBatchMock implements HttpCalloutMock{
        public HttpResponse respond(HttpRequest request){            
            HttpResponse response = new HttpResponse(); 
            String body ='{{"inputs": [{"orderItemIds": ["802KH000000KFSNYA4"]}]}}';
            response.setBody(body);
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);      
            return response;
        }
    }    
}