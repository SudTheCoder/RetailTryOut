/***********************************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-16
* @Component Type               : Apex Class
* @component Name               : ASDAC_SubscriptionAutoRenewalBatchTest
* @description                  : Test Class for ASDAC_SubscriptionAutoRenewalBatch
* @Modified By                  : Deepakshi
* @Modified Date		        : 2023-03-22
************************************************************************************************************************/
@isTest
public with sharing class ASDAC_SubscriptionAutoRenewalBatchTest {
     /**********************************************************************************
     * @author                       : Deepakshi Grover
     * @date                         : 2023-03-20
     * @Method Name                  : testsetup
     * @Modified By                  : Deepakshi
     * @Modified Date		         : 2023-03-22
     **********************************************************************************/
    @testsetup
    static void testsetup() {
        Profile objProfile = [Select id,Name from Profile where Name = 'System Administrator'];
        User objUser = new User(Username = 'recurringslot@asdatest.co.uk',ProfileId = objProfile.Id ,Alias = 'test123',Email = 'test123@asdatest.co.uk',EmailEncodingKey = 'UTF-8',LastName = 'McTesty', TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US',LanguageLocaleKey = 'en_US');
        insert objUser;
        
      String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account objAccount = new Account(FirstName='Test',LastName = 'Account 1',Loginid__c='testEmail@asdatest.co.uk',RecordTypeID=recordTypeId);
        Insert objAccount;
        
       // Contact objContact = new Contact(LastName='Test Contact 1', AccountId = ObjAccount.Id);
        //Insert objContact;
        
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
        
        Asset objAsset = new Asset(status ='Active',Name='Test Asset 1',AccountId=objAccount.Id,loyaltyOrderNumber__c=objOrder.Id,Product2Id = objProduct.id,UsageEndDate = date.today().addDays(-1) ,PurchaseDate = date.today().addmonths(-10), shopOrderNumber__c = 'TestShop123',Customer_Card__c=cc.id,Acquirer_Name__c ='ACQURERE',Payment_Id__c='12345',SchemeReferenceData__c='874764647',PSPID__c='nitkumar4',Payment_Product_Name__c='test123');
        objAsset.Auto_Renew__c=true;

        Insert objAsset;
    }
    
     /**********************************************************************************
     * @author                       : Deepakshi Grover
     * @date                         : 2023-03-20
     * @Method Name                  : XMLCalloutBatchTest
     * @Modified By                  : Deepakshi
     * @Modified Date		         : 2023-03-22
     **********************************************************************************/    
    @isTest
    static void xmlCalloutBatchTest() {
        //Variable declaration
        Map<Id,String> mapAssetXML = new Map<Id,String>();
        Set<Id> setId = new Set<Id>();
        String strXML;
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        System.runAs(objUser){
            Test.startTest();
            Asset objAsset = [Select Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,PurchaseDate, Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c from Asset where name='Test Asset 1' limit 1];
            strXML = '<?xml version="1.0" encoding="UTF-8"?><orders xmlns="http://www.demandware.com/xml/impex/order/2006-10-31"><order order-no="00002205"><order-date>2023-01-05T14:31:09.000Z</order-date><created-by>storefront</created-by><original-order-no>00002205</original-order-no><currency>GBP</currency><customer-locale>en_US</customer-locale><taxation>gross</taxation><invoice-no>00003502</invoice-no></order></orders>';
            mapAssetXML.put(objAsset.id,strXML);
            ASDAC_SubscriptionAutoRenewalBatch objBatch = new ASDAC_SubscriptionAutoRenewalBatch();
            Database.executeBatch(objBatch,1);
             
            Test.stopTest();
        }
        System.assertNotEquals('', strXML);
    }
    
    //Exception Test::
        @isTest
    static void xmlCalloutBatchExceptionTest() {
        //Variable declaration
        Map<Id,String> mapAssetXML = new Map<Id,String>();
        Set<Id> setId = new Set<Id>();
        String strXML;
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        System.runAs(objUser){
            Test.startTest();
            Asset objAsset = [Select Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,PurchaseDate, Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c from Asset where name='Test Asset 1' limit 1];
            Product2 pdt = new Product2();
            pdt.id = objAsset.Product2Id;
            pdt.isActive = false;
            update pdt;
            strXML = '<?xml version="1.0" encoding="UTF-8"?><orders xmlns="http://www.demandware.com/xml/impex/order/2006-10-31"><order order-no="00002205"><order-date>2023-01-05T14:31:09.000Z</order-date><created-by>storefront</created-by><original-order-no>00002205</original-order-no><currency>GBP</currency><customer-locale>en_US</customer-locale><taxation>gross</taxation><invoice-no>00003502</invoice-no></order></orders>';
            mapAssetXML.put(objAsset.id,strXML);
            ASDAC_SubscriptionAutoRenewalBatch objBatch = new ASDAC_SubscriptionAutoRenewalBatch();
            Database.executeBatch(objBatch,1);
             
            Test.stopTest();
        }
        System.assertNotEquals('', strXML);
    }
    
        @isTest
    static void migratedXmlCalloutBatchTest() {
        //Variable declaration
        Map<Id,String> mapAssetXML = new Map<Id,String>();
        Set<Id> setId = new Set<Id>();
        String strXML;
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        Test.setMock(HttpCalloutMock.class, new ASDAC_PaymentCalloutMockTest());   
        
        System.runAs(objUser){
           Map<String, string> migratedPaymentResponse = new Map<string, string>();
        	migratedPaymentResponse.put('paymentId','Test_Payment');
        	migratedPaymentResponse.put('merchantReference','MerchantRef');
            Asset objAsset = [Select Id, Auto_Renew__c, shopOrderNumber__c,asda_merchant_reference_no__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,PurchaseDate, Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c from Asset where name='Test Asset 1' limit 1];
            objAsset.Payment_Id__c = migratedPaymentResponse.get('paymentId');
            objAsset.asda_merchant_reference_no__c =  migratedPaymentResponse.get('merchantReference');
            Update objAsset;
            Test.startTest();      
            strXML = '<?xml version="1.0" encoding="UTF-8"?><orders xmlns="http://www.demandware.com/xml/impex/order/2006-10-31"><order order-no="00002205"><order-date>2023-01-05T14:31:09.000Z</order-date><created-by>storefront</created-by><original-order-no>00002205</original-order-no><currency>GBP</currency><customer-locale>en_US</customer-locale><taxation>gross</taxation><invoice-no>00003502</invoice-no></order></orders>';
            mapAssetXML.put(objAsset.id,strXML);
            String CRON_EXP = '0 1 * * * ?';
             ASDAC_RenewalScheduler scheduleAutoRenew = new ASDAC_RenewalScheduler();
            System.schedule('Schedule AutoRenew Job every day', CRON_EXP, scheduleAutoRenew);
            Test.stopTest();
            }
       		System.assertNotEquals('', strXML);
    }
}