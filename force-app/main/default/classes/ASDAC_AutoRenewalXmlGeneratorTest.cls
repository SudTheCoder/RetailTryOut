/***********************************************************************************************************************
* @author                       : Deepakshi Grover
* @date                         : 2023-03-20
* @Component Type               : Apex Class
* @component Name               : ASDAC_AutoRenewalXmlGeneratorTest
* @description                  : Test Class for ASDAC_AutoRenewalXmlGenerator
* @Modified By                  : Niteesh Kumar
* @Modified Date		         : 2023-03-22
************************************************************************************************************************/
@isTest
public with sharing class ASDAC_AutoRenewalXmlGeneratorTest {
    
     /**********************************************************************************
     * @author                       : Deepakshi Grover
     * @date                         : 2023-03-20
     * @Method Name                  : testsetup
     * @Modified By                  : Deepakshi
     * @Modified Date		         : 2023-03-22
     **********************************************************************************/
    public static final String REQUEST_TYPE = 'Monthly';
    public static final String REQUEST_TYPE_AUTORENEW = 'AutoRenew';

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
        
        Product2 objProduct = new Product2(Name = 'TestProd1',ItemId__c = 'TEST',PlanDuration__c=6,NumberOfInstallments__c=6,PlanPrice__c=7);
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
        
        List<Asset> asstList = new List<Asset>();
        Asset objAsset = new Asset(Name='Test Asset 1',AccountId=objAccount.Id,loyaltyOrderNumber__c=objOrder.Id,Product2Id = objProduct.id,UsageEndDate = date.today().addYears(1) ,PurchaseDate = date.today(), shopOrderNumber__c = 'TestShop123',Customer_Card__c=cc.id,Acquirer_Name__c ='ACQURERE',Payment_Id__c='12345',SchemeReferenceData__c='874764647',PSPID__c='nitkumar4',Payment_Product_Name__c='test123',asda_merchant_reference_no__c ='700000000386621728297110942');
        objAsset.Auto_Renew__c=true;

        Asset objAsset1 = new Asset(Name='TestMigratedAsset',AccountId=objAccount.Id,loyaltyOrderNumber__c=objOrder.Id,Product2Id = objProduct.id,UsageEndDate = date.today().addYears(1) ,PurchaseDate = date.today(), shopOrderNumber__c = 'TestShop123',Customer_Card__c=cc.id,SchemeReferenceData__c='874764647',Payment_Product_Name__c='test123');
        objAsset1.Auto_Renew__c=true;
        objAsset1.isMigratedSubscription__c= true;
        objAsset1.isFirstWorldlineTransactionDone__c = false;
		asstList.add(objAsset);asstList.add(objAsset1);
        Insert asstList;
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
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        System.runAs(objUser){
            Test.startTest();
            Asset objAsset = [Select Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,PurchaseDate, Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c,isMigratedSubscription__c,isFirstWorldlineTransactionDone__c,Customer_Card__r.CardBrand__c,asda_merchant_reference_no__c from Asset where name='Test Asset 1' limit 1];
            String strResponse = '{"creationOutput":{"externalReference":"ec57eb00-e295-41f9-8a02-12b4c3465e9b","token":"ec57eb00-e295-41f9-8a02-12b4c3465e9b" },"payment":{"paymentOutput": { "amountOfMoney": { "amount": 91800,"currencyCode": "EUR" },"references": {"merchantReference": "S2S_TOKEN-1678979906"},"acquiredAmount": {"amount": 91800,"currencyCode": "EUR"},"customer": {"device": {"ipAddressCountryCode": "99"}},"cardPaymentMethodSpecificOutput": {"paymentProductId": 1,"authorisationCode": "1403866403","card": {"cardNumber": "************2022","expiryDate": "1238","bin": "487497", "countryCode": "BE" }, "fraudResults": { "fraudServiceResult": "no-advice","avsResult": "U","cvvResult": "0"},"threeDSecureResults": {"eci": "9","xid": "MzI2MzM1Njk0OA=="},"token": "ec57eb00-e295-41f9-8a02-12b4c3465e9b"},"paymentMethod": "card"},"status": "CAPTURED","statusOutput": {"isCancellable": false, "statusCategory": "COMPLETED", "statusCode": 9, "isAuthorized": false, "isRefundable": true},"id": "3263356948_0"}}';
            ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset, REQUEST_TYPE_AUTORENEW,null);
            Test.stopTest();
        }
        System.assertEquals('AutoRenew',REQUEST_TYPE_AUTORENEW );
        
    }
    @isTest
    static void xmlCalloutMonthlyBatchTest() {
        
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        System.runAs(objUser){
            Test.startTest();
            Asset objAsset = [Select Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,PurchaseDate, Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c,isMigratedSubscription__c,isFirstWorldlineTransactionDone__c,Customer_Card__r.CardBrand__c,asda_merchant_reference_no__c from Asset where name='Test Asset 1' limit 1];
            
            String strResponse = '{"creationOutput":{"externalReference":"ec57eb00-e295-41f9-8a02-12b4c3465e9b","token":"ec57eb00-e295-41f9-8a02-12b4c3465e9b" },"payment":{"paymentOutput": { "amountOfMoney": { "amount": 91800,"currencyCode": "EUR" },"references": {"merchantReference": "S2S_TOKEN-1678979906"},"acquiredAmount": {"amount": 91800,"currencyCode": "EUR"},"customer": {"device": {"ipAddressCountryCode": "99"}},"cardPaymentMethodSpecificOutput": {"paymentProductId": 1,"authorisationCode": "1403866403","card": {"cardNumber": "************2022","expiryDate": "1238","bin": "487497", "countryCode": "BE" }, "fraudResults": { "fraudServiceResult": "no-advice","avsResult": "U","cvvResult": "0"},"threeDSecureResults": {"eci": "9","xid": "MzI2MzM1Njk0OA=="},"token": "ec57eb00-e295-41f9-8a02-12b4c3465e9b"},"paymentMethod": "card"},"status": "CAPTURED","statusOutput": {"isCancellable": false, "statusCategory": "COMPLETED", "statusCode": 9, "isAuthorized": false, "isRefundable": true},"id": "3263356948_0"}}';
            ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset, REQUEST_TYPE,null);
            Test.stopTest();
        }
        System.assertEquals('Monthly',REQUEST_TYPE );
        
    }
     @isTest
    static void migratedMonthlyRecordTest() {
        
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        System.runAs(objUser){
            Test.startTest();
            Asset objAsset = [Select Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,PurchaseDate, Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c,isMigratedSubscription__c,isFirstWorldlineTransactionDone__c,Customer_Card__r.CardBrand__c,asda_merchant_reference_no__c,LoyaltyOrderNo__c from Asset where name='TestMigratedAsset' limit 1];
            
            String strResponse = '{"creationOutput":{"externalReference":"ec57eb00-e295-41f9-8a02-12b4c3465e9b","token":"ec57eb00-e295-41f9-8a02-12b4c3465e9b" },"payment":{"paymentOutput": { "amountOfMoney": { "amount": 91800,"currencyCode": "EUR" },"references": {"merchantReference": "S2S_TOKEN-1678979906"},"acquiredAmount": {"amount": 91800,"currencyCode": "EUR"},"customer": {"device": {"ipAddressCountryCode": "99"}},"cardPaymentMethodSpecificOutput": {"paymentProductId": 1,"authorisationCode": "1403866403","card": {"cardNumber": "************2022","expiryDate": "1238","bin": "487497", "countryCode": "BE" }, "fraudResults": { "fraudServiceResult": "no-advice","avsResult": "U","cvvResult": "0"},"threeDSecureResults": {"eci": "9","xid": "MzI2MzM1Njk0OA=="},"token": "ec57eb00-e295-41f9-8a02-12b4c3465e9b"},"paymentMethod": "card"},"status": "CAPTURED","statusOutput": {"isCancellable": false, "statusCategory": "COMPLETED", "statusCode": 9, "isAuthorized": false, "isRefundable": true},"id": "3263356948_0"}}';
            Test.setMock(HttpCalloutMock.class, new ASDAC_PaymentCalloutMockTest());
             Map<String,string> migratedPaymnetResponse = ASDAC_PaymentResponseWrapper.worldlineAuthenticationRequest(objAsset,REQUEST_TYPE); 
            ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset, REQUEST_TYPE,migratedPaymnetResponse);
            Test.stopTest();
        }
        System.assertEquals('Monthly',REQUEST_TYPE );
        
    }
     @isTest
    static void migratedAutoRenewRecordTest() {
        
        
        User objUser = [Select id,UserName from User where UserName ='recurringslot@asdatest.co.uk' limit 1 ];
        
        System.runAs(objUser){
            Test.startTest();
            Asset objAsset = [Select Id, Auto_Renew__c, shopOrderNumber__c, UsageEndDate, AccountId, loyaltyOrderNumber__c, Product2Id,Is_Product_Active__c,Customer_Card__r.CardToken__c,PurchaseDate, Acquirer_Name__c, Payment_Id__c, SchemeReferenceData__c,cardUpdatdOnDate__c,Renewal_Payment_Failed_Counter__c,Renewal_Payment_Status__c,PSPID__c,Payment_Product_Name__c,isMigratedSubscription__c,isFirstWorldlineTransactionDone__c,Customer_Card__r.CardBrand__c,asda_merchant_reference_no__c,LoyaltyOrderNo__c from Asset where name='TestMigratedAsset' limit 1];
            
            String strResponse = '{"creationOutput":{"externalReference":"ec57eb00-e295-41f9-8a02-12b4c3465e9b","token":"ec57eb00-e295-41f9-8a02-12b4c3465e9b" },"payment":{"paymentOutput": { "amountOfMoney": { "amount": 695,"currencyCode": "EUR" },"references": {"merchantReference": "48547858581678979906"},"acquiredAmount": {"amount": 695,"currencyCode": "EUR"},"customer": {"device": {"ipAddressCountryCode": "99"}},"cardPaymentMethodSpecificOutput": {"paymentProductId": 1,"authorisationCode": "1403866403","card": {"cardNumber": "************2022","expiryDate": "1238","bin": "487497", "countryCode": "BE" }, "fraudResults": { "fraudServiceResult": "no-advice","avsResult": "U","cvvResult": "0"},"threeDSecureResults": {"eci": "9","xid": "MzI2MzM1Njk0OA=="},"token": "ec57eb00-e295-41f9-8a02-12b4c3465e9b"},"paymentMethod": "card"},"status": "CAPTURED","statusOutput": {"isCancellable": false, "statusCategory": "COMPLETED", "statusCode": 9, "isAuthorized": false, "isRefundable": true},"id": "3263356948_0"}}';
            Test.setMock(HttpCalloutMock.class, new ASDAC_PaymentCalloutMockTest());
            Map<String,string> migratedPaymnetResponse = ASDAC_PaymentResponseWrapper.worldlineAuthenticationRequest(objAsset,REQUEST_TYPE_AUTORENEW); 
            ASDAC_AutoRenewalXmlGenerator.xmlRequestGenerator(objAsset, REQUEST_TYPE_AUTORENEW,migratedPaymnetResponse);
            Test.stopTest();
        }
        System.assertEquals('AutoRenew',REQUEST_TYPE_AUTORENEW );
        
    }
}